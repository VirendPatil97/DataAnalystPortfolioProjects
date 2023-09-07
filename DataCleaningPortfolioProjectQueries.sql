/* Cleaning Data in SQL */

----- Dataset we are gonna work with ( Nashville Housing Data)

---- lets look at the dataset
Select top 50 * from NashvilleHousing

--- Standardize Date Format
update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)


---- Populate property address data
select a.UniqueID, a.ParcelID, a.PropertyAddress,b.UniqueID, b.ParcelID, b.PropertyAddress from NashvilleHousing a
join NashvilleHousing b ON
a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b ON
a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--- Breaking out the Address into individual columns (Address, city , state)


alter table NashvilleHousing
add PropertySplitAddress VARCHAR(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity VARCHAR(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))





alter table NashvilleHousing
add OwnerSplitAddress VARCHAR(255)

alter table NashvilleHousing
add OwnerSplitCity VARCHAR(255)

alter table NashvilleHousing
add OwnerSplitState VARCHAR(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field
select SoldAsVacant, count(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant
order by 2


update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
                    when SoldAsVacant='N' then 'No'
                    else SoldAsVacant
                    end


---- Remove Duplicates 
with RowNumCTE 
AS (
    select *,
ROW_NUMBER() OVER (PARTITION by ParcelId,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference Order by UniqueID)row_num
 from NashvilleHousing

)

 
delete from RowNumCTE
where row_num>1

select * from RowNumCTE where row_num>1


---Delete columns

alter table NashvilleHousing
drop OwnerAddress, TaxDistrict, PropertyAddress