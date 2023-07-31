/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDate2, CONVERT(date,SaleDate)
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Select SaleDate
From PortfolioProject..NashvilleHousing
-- Add a new Column for table 
Alter Table PortfolioProject..NashvilleHousing 
Add SaleDate2 Date
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set SaleDate2 = CONVERT(date,SaleDate)






 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


-- locate the property is null
Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

-- Sort the dateset and find out that same ParcelIDs with same address

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID

-- slef join 
Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID    -- use this condition will make the table match with null
   and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- Use ISNULL function to get the PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress )
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID    -- use this condition will make the table match with null
   and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- update the propertyaddress with isnull(a.PropertyAddress,b.PropertyAddress )
Update a
Set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID    -- use this condition will make the table match with null
   and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null











--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
    -- find the address coloum 

Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- Apply the substring to get break the colums.

Select 
PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, len(propertyaddress)) as City
From PortfolioProject..NashvilleHousing

-- add the new colums in the table

Alter Table PortfolioProject..NashvilleHousing 
Add Address Char(255)
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1)


Alter Table PortfolioProject..NashvilleHousing 
Add City Char(255)
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, len(propertyaddress))

Select city, address
from PortfolioProject..NashvilleHousing

-- owneraddress
Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS OwnerState, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS OwnerCity
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS OwnerAddress
From PortfolioProject..NashvilleHousing
Where OwnerAddress is not null

Alter Table PortfolioProject..NashvilleHousing 
Add OwnerState Char(255)
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 

Alter Table PortfolioProject..NashvilleHousing 
Add OwnerCity Char(255)
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) 

Alter Table PortfolioProject..NashvilleHousing 
Add OwnerStreet Char(255)
-- insert date data in the column.
Update PortfolioProject..NashvilleHousing
Set OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 

Select *
From PortfolioProject..NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select DISTINCT SoldAsVacant
From PortfolioProject..NashvilleHousing

Select SoldAsVacant, count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 

Case When SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant ='N' then 'No'
	 Else SoldAsVacant
	 End              
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant ='N' then 'No'
	 Else SoldAsVacant
	 End   

Select DISTINCT SoldAsVacant, count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicateselements

 -- Indentify the duplicates: Find all old be unique as to check that duplicates.
 -- Parcel ID, PropertyAddress, saledate, SalePrice, LegalRefereence
Select *
From PortfolioProject..NashvilleHousing

With RownumCTE as (
Select *, ROW_NUMBER()over(
   Partition by
                ParcelID,
				PropertyAddress,
				Saledate,
				SalePrice,
				LegalReference
	Order by uniqueID
   ) RN
From PortfolioProject..NashvilleHousing)

--Delete
--From RownumCTE
--Where RN >1

Select *
From RownumCTE
Where RN >1








---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column SalePrice, OwnerAddress, TaxDistrict














-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
