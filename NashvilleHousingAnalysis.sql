Select * 
From [Portfolio Project 2]..NashvilleHousing

--Standardize date format

Select SaleDate
From [Portfolio Project 2]..NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted
From [Portfolio Project 2]..NashvilleHousing

--Populate PropertyAddress column when address is null

Select *
From [Portfolio Project 2]..NashvilleHousing
where PropertyAddress is null

Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 2]..NashvilleHousing a
JOIN [Portfolio Project 2]..NashvilleHousing b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 2]..NashvilleHousing a
JOIN [Portfolio Project 2]..NashvilleHousing b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Splitting PropertyAddress in Address and City

Select PropertyAddress
From [Portfolio Project 2]..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
From [Portfolio Project 2]..NashvilleHousing

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project 2]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update [Portfolio Project 2]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

--Spliting OwnerAddress column in address, city and state

Select OwnerAddress
From [Portfolio Project 2]..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as address ,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as city ,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as state
From [Portfolio Project 2]..NashvilleHousing

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project 2]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project 2]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update [Portfolio Project 2]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--change Y and N to Yes and No in SoldAsVacant column

SELECT DISTINCT (SoldAsVacant), count (SoldAsVacant) as count
From [Portfolio Project 2]..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From [Portfolio Project 2]..NashvilleHousing

Update [Portfolio Project 2]..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove duplicates

WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) as row_num
From [Portfolio Project 2]..NashvilleHousing)

DELETE
From RowNumCTE
Where row_num > 1

--Delete Unused columns

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project 2]..NashvilleHousing
DROP COLUMN SaleDate