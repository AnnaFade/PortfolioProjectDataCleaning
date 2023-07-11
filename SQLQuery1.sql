/* Cleaning Data in SQL Queries */

Select *
From DataCleaningPortfolioProject.dbo.NashvilleHousing


---------- Standardize Data Format-------------

Select SaleDateConverted, CONVERT(Date, SaleDate)
From DataCleaningPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = CONVERT(Date, SaleDate)



--------- Populate Property Address Data -----------

Select *
From DataCleaningPortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningPortfolioProject.dbo.NashvilleHousing a
JOIN DataCleaningPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningPortfolioProject.dbo.NashvilleHousing a
JOIN DataCleaningPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---------Breaking out Address into Individual Columns (Address, City, State)---------- 

Select PropertyAddress
From DataCleaningPortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From DataCleaningPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVarChar(255);

Update NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVarChar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From DataCleaningPortfolioProject.dbo.NashvilleHousing




Select OwnerAddress
From DataCleaningPortfolioProject.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From DataCleaningPortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)




--------------Change Y and N to Yes and No in "Sold as Vacant Field"----------------


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningPortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	END 
FROM DataCleaningPortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	END 



----------------Removing Duplicates -----------------


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
FROM DataCleaningPortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress




------------------Deleting Unused Columns ------------------ 


Select *
FROM DataCleaningPortfolioProject.dbo.NashvilleHousing


ALTER TABLE DataCleaningPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate