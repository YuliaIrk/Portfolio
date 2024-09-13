--Looking at total cases of infected vs total deaths
select location, date, total_cases, total_deaths, (total_deaths:: numeric)/(total_cases:: numeric)*100 as deaths_percentage
from deaths
where continent is not Null;

--Looking at total cases of infected vs population
--Shows what percentage of population has got infected in location 'Ukraine'
select location, date, total_cases, population, (total_cases:: numeric)/(population:: numeric)*100 as cases_percentage
from deaths
where location = 'Ukraine'
order by 1,2;

--Looking at continents where was the highest infection rate comparing to population 

select location, max(total_cases) as highest_inf_count, max((total_cases:: numeric)/(population:: numeric)*100) as max_cases_percentage
from deaths
where continent is Null
group by location
having max(total_cases) is not Null
order by 3 desc;

--GLOBAL
--Looking at the global figures on new deaths, new cases and percentage of deaths vs infected cases grouped by date 
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths):: numeric)/(sum(new_cases):: numeric)*100 as deaths_percentage
from deaths
where continent is not Null
group by date
order by 1;


--Looking at total vaccination comparing to population by location by date.
--Created a column 'rolling_vac' to show the daily changes in number of people vaccinated
select d.continent, d.location, d.date, d.population, new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vac
from deaths d
join vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3

--CTE
--Using CTE to create a new column 'rolling_vac_pop' which shows rolling percentage 
--figure of daily vaccinations comparing to population by country
with t1 as
(
select d.continent, d.location, d.date, d.population, new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vac
from deaths d
join vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null
)
select *, rolling_vac/population *100 as rolling_vac_pop
from t1
order by 2,3

-- TEMP table
-- Using the same joined tables I created a temporary table to work with this dataset during 
-- one session if it is needed

drop table if exists PercentPopulationVaccinated

create temp table PercentPopulationVaccinated(continent character varying(50),
 location character varying (50),
 date date,
 population bigint,
 new_vaccinations bigint,
 rolling_vac bigint
)

insert into PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vac
from deaths d
join vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null

select *, rolling_vac/population *100 as rolling_vac_pop
from PercentPopulationVaccinated

-- Create Views to store the data for visualizations

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vac
from deaths d
join vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null


-- For Tableau
--Table 1 death percentage
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths):: numeric)/(sum(new_cases):: numeric)*100 as deaths_percentage
from deaths
where continent is not Null

--Table 2 death sum by location
select location, sum(new_deaths) as total_deaths_sum
from deaths
where continent is Null and location not in ('European Union', 'World')
group by location
order by 2 desc

--Table 3 highest indicator of infection cases by location
select location, population, max(total_cases) as highest_inf_count, max((total_cases:: numeric)/(population:: numeric)*100) as max_cases_percentage
from deaths
group by location, population
having max(total_cases) is not Null
order by 4 desc;

--Table 4 highest indicator of infection cases by location and by date
select date,location, population, max(total_cases) as highest_inf_count, max((total_cases:: numeric)/(population:: numeric)*100) as max_cases_percentage
from deaths
group by location, population, date
having max(total_cases) is not Null
order by max_cases_percentage desc;
