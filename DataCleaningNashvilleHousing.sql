/*

DATA CLEANING Project 

*/

--Changing the date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populating the Property Address 

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as Populated_Address
From PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking Out Address into Individual Collums (Address, City, State)
Select PropertyAddress 
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
ADD PropertySpiltAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySpiltAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySpiltCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 --Breaking Up the Owner Address

Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing

Alter Table NashvilleHousing
ADD OwnerSpiltAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
ADD OwnerSpiltCity Nvarchar(255);

Update NashvilleHousing 
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
ADD OwnerSpiltState Nvarchar(255);

Update NashvilleHousing 
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Changing 'Y' and 'N' as 'Yes' and 'No' in the sold as Vacant Field

Select Distinct (SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group BY SoldAsVacant
Order by 2

Select SoldAsVacant,
	Case when SoldAsVacant = 'Y' THEN 'Yes'
	     when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
						when SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
)
Select * 
From RowNumCTE
WHERE row_num > 1
Order BY PropertyAddress

--Deleting Unused Collums
Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

