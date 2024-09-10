--In this project I was cleaning the data from file 
--Nashville Housing Data for Data Cleaning (reuploaded).xlsx
--which represents information about addresses, contacts of the owners, dates of sale, prices, etc

--Standardization of date column
select *
from Covid.dbo.housing;

--Standartize date in  SaleDate column to the format year-month-day
alter table	housing
add  SaleDateConv Date;

update housing
set SaleDateConv=CONVERT(date,saledate);

--Property Address
--Contains Nulls. Lets get rid of them using ParcelID and duplicates- if there are duplicates in parcelID 
--and PropertyAddress is not Null, then copy address to the column which doesn't have one.
select *
from dbo.housing
where PropertyAddress is Null
order by ParcelID;

select a.ParcelID ,a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing a
join dbo.housing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is Null;

--Using self join we copied address from duplicate rows and altered table 
update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing a
join dbo.housing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is Null;


--Split the propertyaddress column into 2 -  address, city
select 
SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)-1, LEN(PropertyAddress))
from dbo.housing;

--Updating the table with 2 new columns

alter table	housing
add  PropertyAddressSplit Nvarchar(200);

update housing
set PropertyAddressSplit=SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',', PropertyAddress)-1);

alter table	housing
add  PropertyAddressCity Nvarchar(200);

update housing
set PropertyAddressCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--Split the owneraddress column into 3 -  address, city,state

select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from housing;

--Updating the table with 3 new columns

alter table	housing
add  OwnerAddressSplit Nvarchar(255),
	OwnerAddressCity Nvarchar(255),
	OwnerAddressState Nvarchar(255);

update housing
set OwnerAddressSplit=PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
set OwnerAddressCity=PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
set OwnerAddressState=PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

--Looking through the data in the SoldAsVacant column, where there are some inconsistent values Y and N

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from housing
group by SoldAsVacant;

select SoldAsVacant, 
CASE when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from housing;

--Updating the table with changed data

update housing
set SoldAsVacant = CASE when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

-- Finding duplicates with help of row_number function and partition by
With RowNumCTE as (
select *, ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				Order by UniqueID) row_num
from housing)
Delete
from RowNumCTE
where row_num >1;


