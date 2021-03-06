--Cleaning data in SQL
Select *
From
PortfolioProject..HousingData$

-----------------------------------------------------------------------------------------------------------------
--Stadardize the date format
select SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..HousingData$

ALTER TABLE HousingData$
ADD SalesConverted Date;

UPDATE HousingData$
SET SalesConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------
--populate the property address for misssing rows
SELECT *
FROM PortfolioProject..HousingData$
WHERE PropertyAddress is null

----The propertyadress column consisting of nulls, has other information in the other columns, so it can not be removed
---in this case, we shall look for how to populate it. loook for another column with repeated values 
SELECT *
FROM PortfolioProject..HousingData$
order by ParcelID


--next, check the rows where parcel_id are equal to one another

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..HousingData$ a
JOIN PortfolioProject..HousingData$ b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..HousingData$ a
JOIN PortfolioProject..HousingData$ b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--create another column with the nulls and populate all the nulls with value in b.propertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData$ a
JOIN PortfolioProject..HousingData$ b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---Next update the tble to populate the (a.PropertyAddress where is null) with values here ( ISNULL(a.PropertyAddress, b.PropertyAddress)
Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData$ a
JOIN PortfolioProject..HousingData$ b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

SELECT *
FROM PortfolioProject..HousingData$
WHERE PropertyAddress is null ------No more nulls


--------------------------------------------------------------------------------------------------------------------------------------------
--Splitting up the addtrss column into individual column of address, city, state
--SUBSTR (country, 1, 2)='US' (count from first letter  and count to 2)/
---1 to remove comma from the result/ Charindex means stop at comma)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM PortfolioProject..HousingData$

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..HousingData$

ALTER TABLE HousingData$
ADD PropertySPlitAddress Nvarchar(255);

UPDATE HousingData$
SET PropertySPlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData$
ADD PropertySPlitCity Nvarchar(255);

UPDATE HousingData$
SET PropertySPlitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

 -------------------------------------------------------------------------------------------------------------

 --splitting the OwnerAddress column
 
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..HousingData$

ALTER TABLE HousingData$
ADD OwnerAddressSplitAddress Nvarchar(255);

UPDATE HousingData$
SET OwnerAddressSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE HousingData$
ADD OwnerAddressSplitCity Nvarchar(255);

UPDATE HousingData$
SET OwnerAddressSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE HousingData$
ADD OwnerAddressSplitState Nvarchar(255);

UPDATE HousingData$
SET OwnerAddressSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------

------change the Boolean column consisting of varied yes and no 
--but first, check it out
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..HousingData$
GROUP BY SoldAsVacant
Order by 2


---change all N TO NO AND Y to yes
Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..HousingData$ 


UPDATE HousingData$
SET SoldAsVacant= 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------

--remove duplicates
--partition by important columns that must not be duplicated . eg sales, leaglid, address
Select *,
ROW_NUMBER() OVER(PARTITION BY
				  ParcelID,
				  PropertyAddress,
				  SaleDate,
				  LegalReference
				  ORDER BY
						UniqueID
					)   row_num
FROM PortfolioProject..HousingData$ 

---------ideally the row_num should be 1 anynumber aside this means duplicate, however, if you cant find it, use a cte

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(PARTITION BY
				  ParcelID,
				  PropertyAddress,
				  SaleDate,
				  LegalReference
				  ORDER BY
						UniqueID
						)row_num
FROM PortfolioProject..HousingData$
)
Select *
FROM RowNumCTE
where row_num > 1
order by PropertyAddress


---------then delete the rows

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(PARTITION BY
				  ParcelID,
				  PropertyAddress,
				  SaleDate,
				  LegalReference
				  ORDER BY
						UniqueID
						)row_num
FROM PortfolioProject..HousingData$
)
DELETE 
FROM RowNumCTE
where row_num > 1
--order by PropertyAddress (104 ROWS DELETED)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(PARTITION BY
				  ParcelID,
				  PropertyAddress,
				  SaleDate,
				  LegalReference
				  ORDER BY
						UniqueID
						)row_num
FROM PortfolioProject..HousingData$
)
SELECT * 
FROM RowNumCTE
where row_num > 1

-------------------------------------------------------------------------------------------------------------------------------------------------

---DELETE UNUSED COLUMNS
ALTER TABLE PortfolioProject..HousingData$
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

SELECT *
FROM PortfolioProject..HousingData$

ALTER TABLE PortfolioProject..HousingData$
DROP COLUMN SALEDATE