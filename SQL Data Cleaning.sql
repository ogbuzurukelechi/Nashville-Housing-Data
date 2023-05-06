select	*
from Nashville_data;

--altering and Updating the table to include a standardized date format

alter table Nashville_data
add SaleDateConverted Date;

update Nashville_data
set SaleDateConverted = CONVERT(date,SaleDate);

-- Populating Property Address data with NULL value
select
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_data a
join Nashville_data b
	on a.ParcelID = b.ParcelID
	and	a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_data a
join Nashville_data b
	on a.ParcelID = b.ParcelID
	and	a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- Breaking Property Address into columns (Address, City) using substring

select *
from Nashville_data;

select
SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Nashville_data;

alter table Nashville_data
add PropertySplitAddress nvarchar(255);

update Nashville_data
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1);

alter table Nashville_data
add PropertySplitCity nvarchar(255);

update Nashville_data
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

-- -- Breaking Property Address into columns (Address, City, State) using Parsename

select 
parsename(replace(OwnerAddress,',','.'),3) as Address,
parsename(replace(OwnerAddress,',','.'),2) as City,
parsename(replace(OwnerAddress,',','.'),1) as State
from Nashville_data;

alter table Nashville_data
add OwnerSplitAddress nvarchar(255);

update Nashville_data
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table Nashville_data
add OwnerSplitCity nvarchar(255);

update Nashville_data
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table Nashville_data
add OwnerSplitState nvarchar(255);

update Nashville_data
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


-- Changing Y and N to Yes and No in "SoldAsVacant" column
select
	Soldasvacant,
	CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
		 else Soldasvacant
	END
from Nashville_data;

update Nashville_data
set SoldAsVacant = CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
		 else Soldasvacant
	END

-- Remove Duplicates
--detecting the duplicates using rownumber

with RowNumCTE as (
select 
	ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SalePrice,
					 LegalReference
					 ORDER BY
						UniqueID
					) as row_num,
		*
from Nashville_data
)
select *
from RowNumCTE
where row_num > 1;

with RowNumCTE as (
select 
	ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SalePrice,
					 LegalReference
					 ORDER BY
						UniqueID
					) as row_num,
		*
from Nashville_data
)
delete
from RowNumCTE
where row_num > 1;

--Delete unused columns

alter table Nashville_data
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

select *
from Nashville_data;
