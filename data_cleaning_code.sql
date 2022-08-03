/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Portfolio_project.dbo.nashvillehousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(DATE,SaleDate)

-- it doesn't Update properly, SO 

ALTER TABLE nashvillehousing
ADD saledateconverted DATE

UPDATE nashvillehousing
SET saledateconverted = CONVERT(DATE,SaleDate)


SELECT *
FROM nashvillehousing

-- we can remove saledate column at end if we want.


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT PropertyAddress , ParcelID
FROM nashvillehousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

-- we founded when 2 parcel id is same then propert address is also same. so we can use that to populate the propertyaddress.
-- lets check by SELF JOIN.

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress) 
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL
-- so now we can see the property address  for null cell. we need to UPDATE.
UPDATE a
SET a.PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress) 
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID

SELECT *
FROM nashvillehousing
WHERE PropertyAddress is NULL
-- THERE IS NO NULL FIELD.


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM nashvillehousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS address
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD propertysplitaddress NVARCHAR(255)

UPDATE nashvillehousing
SET propertysplitaddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD propertysplitcity Nvarchar(255)

UPDATE nashvillehousing
SET propertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

SELECT *
FROM nashvillehousing

-- owneraddress

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD ownersplitaddress Nvarchar(255)

UPDATE nashvillehousing
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
ADD ownersplitcity Nvarchar(255)

UPDATE nashvillehousing
SET ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvillehousing
ADD ownersplitstate Nvarchar(255)

UPDATE nashvillehousing
SET ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM nashvillehousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldASVacant


SELECT SoldAsVacant ,
CASE
    When SoldAsVacant = 'Y' THEN  'Yes' 
	When SoldAsVacant = 'N' THEN  'No'
	ELSE SoldAsVacant
 END
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = 
CASE
    When SoldAsVacant = 'Y' THEN  'Yes' 
	When SoldAsVacant = 'N' THEN  'No'
	ELSE SoldAsVacant
 END
FROM nashvillehousing

SELECT DISTINCT(SoldAsVacant)
FROM nashvillehousing


---------------------------------------------------------------------------------------------------------------------------------------------------------
----REMOVE DUPLICATES


WITH RowNumCTE AS(
SELECT *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID 
					) row_num
FROM nashvillehousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashvillehousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM nashvillehousing



