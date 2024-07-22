select location, date, total_cases, total_deaths, (total_deaths:: numeric)/(total_cases:: numeric)*100 as deaths_percentage
from deaths
where continent is not Null

select location, date, total_cases, population, (total_cases:: numeric)/(population:: numeric)*100 as cases_percentage
from deaths
where location = 'Ukraine'
order by 1,2;

select location, max(total_cases) as highest_inf_count, max((total_cases:: numeric)/(population:: numeric)*100) as max_cases_percentage
from deaths
where continent is Null
group by location
having max(total_cases) is not Null
order by 3 desc;

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths):: numeric)/(sum(new_cases):: numeric)*100 as deaths_percentage
from deaths
where continent is not Null and total_cases>0 and new_cases>0
group by date
order by date;

select d.continent, d.location, d.date, d.population, new_vaccinations, 
sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as rolling_vac
from deaths d
join vaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3


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


-- For Tableau
--Table 1 death percentage
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths):: numeric)/(sum(new_cases):: numeric)*100 as deaths_percentage
from deaths
where continent is not Null


--Table 2 death sum by location
select location, sum(new_deaths) as total_deaths_sum
from deaths
where continent is Null and location <>('World')
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