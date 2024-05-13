-- The whole purpose of this project is to make the Data more usable by cleaning, standarizing the data


Select *
From dbo.[Project Dataset]

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data. I noticed that there's some Null Values so I figured I would populate them
-- Notice how some fileds have a dulpicate ParcelID 
Select *
From dbo.[Project Dataset]
--Where propertyaddress is null
order by parcelid



-- we're ppulating the addresses that have NULL vaules 
Select a.parcelID, a.propertyAddress, b.parcelID, b.propertyAddress, isnull(a.propertyaddress, b.propertyAddress)
From dbo.[Project Dataset] a
JOIN dbo.[Project Dataset] b
On a.parcelID = b.parcelID
AND a.[uniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is null



Update a
SET propertyaddress = isnull(a.propertyaddress, b.propertyAddress)
From dbo.[Project Dataset] a
JOIN dbo.[Project Dataset] b
On a.parcelID = b.parcelID
AND a.[uniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is null

---------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out addresses into indvidual columns (Address, City, State)
Select PropertyAddress
From dbo.[Project Dataset]


SELECT
SUBSTRING( propertyAddress, 1, charindex(',', propertyaddress) -1) As address
, SUBSTRING( propertyAddress, charindex(',', propertyaddress) + 1, Len(propertyAddress)) as Address
From dbo.[Project Dataset]



Alter table dbo.[Project Dataset]
add propertysplitaddress nvarchar(255);

Update dbo.[Project Dataset]
set propertysplitaddress = SUBSTRING( propertyAddress, 1, charindex(',', propertyaddress) -1)


ALter Table dbo.[Project Dataset]
add propertysplitcity nvarchar(255);

update dbo.[Project Dataset]
set propertysplitcity = SUBSTRING( propertyAddress, charindex(',', propertyaddress) + 1, Len(propertyAddress))


-------------------------------------------------------------------------------------------------------------------------------------------
-- Now we want to do the same thing with the OwnerAddress Table but in a less complicated way.
-- The OwnerAddress table has the Street, City, and State all in one column. we're about to change that


-- Step one: Separate them
Select Owneraddress
FROM dbo.[Project Dataset]


Select
parsename(REPLACE(OwnerAddress,',', '.') ,3)-- Parsename is only useful with Periods. that's what it looks for, we can use the REPLACE to replace commas with periods
,parsename(REPLACE(OwnerAddress,',', '.') ,2) -- we're replicating because the 1 above is TN, it's backwards when you use Parsename
,parsename(REPLACE(OwnerAddress,',', '.') ,1)
From dbo.[Project Dataset]


-- Step 2: Add the new Columns
Alter table dbo.[Project Dataset]
Add OwenerSreetAddress nvarchar(255);


-- Step 3: Add the streetaddress to the new table that we created in step two
Update dbo.[Project Dataset]
set OwnerSreetAddress = parsename(REPLACE(OwnerAddress,',', '.') ,3)

-- DONE!!! Repeat the same for and city and state

Alter Table dbo.[Project Dataset]
Add OwnerCityAddress nvarchar(255)

Update dbo.[Project Dataset]
set OwnerCityAddress = parsename(REPLACE(OwnerAddress,',', '.') ,2)

Alter table dbo.[Project Dataset]
Add OwnerStateAddress NVARCHAR(255)


Update dbo.[Project Dataset]
set OwnerStateAddress = parsename(REPLACE(OwnerAddress,',', '.') ,1)


--Note: Best Practice would be creating all of the columns first and then add data to the newly created column
-----------------------------------------------------------------------------------------------------------------------


-- Change the Data of the the column. I want to change all 0s to No and all 1s to Yes in the soldasvacant Column
Select Distinct soldasvacant
from dbo.[Project Dataset]

--Step 1: you need to change the Data type of the column to string because it's currently Boalean which mean that it only stores 1 and 0
ALTER TABLE dbo.[Project Dataset]
ALTER COLUMN Soldasvacant VARCHAR(3);


-- Step 2: Use the Case query to update all 0s to NO and 1s to Yes
Update dbo.[Project Dataset]
set Soldasvacant =
					CASE
						When Soldasvacant = 0 Then 'NO'
						When Soldasvacant = 1 Then 'Yes'
						End;
------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (note; don't delete data in your currentl Database in real life)

WITH RowNumCTE AS(
Select *,
	Row_number() over(
	Partition BY ParcelID,
				propertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) Row_num

From dbo.[Project Dataset]
)
Select *
FROM RowNumCTE
WHERE row_NUM > 1
ORDER by propertyAddress



-----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM dbo.[Project Dataset]


ALTER TABLE dbo.[Project Dataset]
DROP Column SaleDate

