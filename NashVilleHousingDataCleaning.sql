Select *
from NashvilleHousing.dbo.NashvilleHousing


--standardize the SaleDate into date format
Select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=CONVERT(Date, SaleDate)

Select SaleDateConverted
from NashvilleHousing.dbo.NashvilleHousing


--Populate PropertyAddress Data
Select *
from NashvilleHousing.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(b.PropertyAddress, a.PropertyAddress)
from NashvilleHousing.dbo.NashvilleHousing a
join NashvilleHousing.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where b.PropertyAddress is null

update b
set ParcelID= isnull(b.PropertyAddress, a.PropertyAddress)
from NashvilleHousing.dbo.NashvilleHousing a
join NashvilleHousing.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where b.PropertyAddress is null

Select *
from NashvilleHousing.dbo.NashvilleHousing

select c.ParcelID, c.PropertyAddress,c.OwnerName, d.ParcelID, d.PropertyAddress, d.OwnerName, isnull(c.PropertyAddress, c.ParcelID)
from NashvilleHousing.dbo.NashvilleHousing c
join NashvilleHousing.dbo.NashvilleHousing d
on c.OwnerName=d.OwnerName
and c.[UniqueID]<>d.[UniqueID]
Where c.PropertyAddress is null

update c
set PropertyAddress=isnull(c.PropertyAddress, c.ParcelID)
from NashvilleHousing.dbo.NashvilleHousing c
join NashvilleHousing.dbo.NashvilleHousing d
on c.OwnerName=d.OwnerName
and c.[UniqueID]<>d.[UniqueID]
Where c.PropertyAddress is null

select e.ParcelID, e.PropertyAddress, e.OwnerName, f.ParcelID, f.PropertyAddress, f.OwnerName
from NashvilleHousing.dbo.NashvilleHousing e
join NashvilleHousing.dbo.NashvilleHousing f
on e.OwnerName=f.OwnerName
and e.[UniqueID]<>f.[UniqueID]
where f.ParcelID=f.PropertyAddress

update f
set ParcelID= e.ParcelID
from NashvilleHousing.dbo.NashvilleHousing e
join NashvilleHousing.dbo.NashvilleHousing f
on e.OwnerName=f.OwnerName
and e.[UniqueID]<>f.[UniqueID]
where f.ParcelID=f.PropertyAddress
and e.OwnerName <> 'BREWER%' and f.OwnerName <> 'BREWER%'

Select *
from NashvilleHousing.dbo.NashvilleHousing


--breaking the PropertyAddress into individual column of address, and city
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as city
from NashvilleHousing.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from NashvilleHousing.dbo.NashvilleHousing


--Split OnwerAddress into individual columns of Address, city and state
select 
PARSENAME(replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
from NashvilleHousing.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

Select *
from NashvilleHousing.dbo.NashvilleHousing


--change 'Y' to Yes and 'N' to No in the 'SoldAsVacant' column
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end


--remove duplicates using CTE
with RowNumCTE as
(select *,
ROW_NUMBER() over(
partition by ParcelId,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID)row_num
from NashvilleHousing.dbo.NashvilleHousing)
select *
From RowNumCTE
where row_num>1
Order by PropertyAddress

--delete
--From RowNumCTE
--where row_num>1


--delete unnecessary column
alter table NashvilleHousing
drop column SaleDate;

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress

select *
from NashvilleHousing.dbo.NashvilleHousing