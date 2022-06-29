select * from
Projects..NashvilleHousing

--Standardize sale date format
ALTER table Projects..NashvilleHousing
alter column SaleDate date
select * from
Projects..NashvilleHousing

--Populate property address data
--because parcel id is same for same address so if parcel id is known then the same parcel ids have same address
update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)--- if a.propertyadress is null then update it with b.propertyaddress
from Projects..NashvilleHousing a
join Projects..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>B.[UniqueID ] --a table unique id not equal to b's unique id
where a.PropertyAddress is null

--Separating property address into address and city columns
select
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)as Propertysplitaddress, --charindex is giving the position of "," 
substring(PropertyAddress,charindex(',',PropertyAddress )+1 ,len(PropertyAddress)) as PropertySplitcity
from Projects..NashvilleHousing

--adding city and address column to table
alter table Projects..NashvilleHousing
add Propertysplitaddress varchar(450)
, PropertySplitcity varchar(200)
--updating the info into address and city column
update Projects..NashvilleHousing
set Propertysplitaddress =substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)
update Projects..NashvilleHousing
set PropertySplitcity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select * from
Projects..NashvilleHousing

--spliting the owner address into address,city, state using parsename
select
parsename(replace(OwnerAddress,',','.'),3) --as parse fuction works only with '.' delimeter hence repace',' with '.'and parsename works from end like to get the first part of address we are typing 3 which is 3rd prt from end
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
from
Projects..NashvilleHousing

--adding the owner address split address into new columns
alter table Projects..NashvilleHousing
add ownersplitaddress varchar(450)
, ownersplitcity varchar(200)
,ownersplitstate varchar(200)
--updating the new columns
update Projects..NashvilleHousing
set ownersplitaddress=parsename(replace(OwnerAddress,',','.'),3)
update Projects..NashvilleHousing
set ownersplitcity=parsename(replace(OwnerAddress,',','.'),2)
update Projects..NashvilleHousing
set ownersplitstate=parsename(replace(OwnerAddress,',','.'),1)

select * from
Projects..NashvilleHousing

--checking about "sold as vacant" and counting them

select distinct(SoldAsVacant), count(SoldAsVacant)
from Projects..NashvilleHousing
group by SoldAsVacant
order by 2

---changin Y to Yes and N to No in sold as vacant column
select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from Projects..NashvilleHousing

--updating the above change into table
update  Projects..NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end

select * from
Projects..NashvilleHousing

--Remove dupicates
with RowNumCTE as(
select*,
ROW_NUMBER() over(
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID)
row_num
from
Projects..NashvilleHousing
)
select * --this will show all the dupicates
from RowNumCTE
where row_num>1
order by PropertyAddress

delete  --this will delete all the dupicates
from RowNumCTE
where row_num>1

--Delete unused columns
alter table Projects..NashvilleHousing
drop column  OwnerAddress, PropertyAddress

select* from  Projects..NashvilleHousing

