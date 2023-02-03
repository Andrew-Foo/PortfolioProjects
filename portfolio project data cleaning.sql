use portfolio_project;
drop table nashvilledatacleaning;
truncate table nashvilledatacleaning;
load data local infile 'D:\\porfolio creation files\\Nashville Housing Data for Data Cleaning.csv' into table nashvilledatacleaning 
fields terminated by ',' ENCLOSED BY '"' Lines terminated by '\r\n' Ignore 1 lines;
select* from nashvilledatacleaning;
select* from nashvilledatacleaning where propertyaddress is null;

#Filling the Nulls in propertyaddress using joins
select a.parcelid,a.propertyaddress, b.parcelid,b.propertyaddress, ifnull(a.propertyaddress,b.propertyaddress) as replacement 
from nashvilledatacleaning a join nashvilledatacleaning b on a.ParcelID = b.ParcelID and a.ï»¿UniqueID != b.ï»¿UniqueID where a.propertyaddress is null;
update nashvilledatacleaning a join nashvilledatacleaning b on a.ParcelID = b.ParcelID and a.ï»¿UniqueID != b.ï»¿UniqueID
set a.propertyaddress = ifnull(a.propertyaddress,b.propertyaddress)  where a.propertyaddress is null;
select* from nashvilledatacleaning where propertyaddress is null;

#splitting address from city
select substring(propertyaddress,1, Locate(',',propertyaddress)-1) as address, substring(propertyaddress, Locate(',',propertyaddress)+1, length(propertyaddress)) as address 
from nashvilledatacleaning;
alter table nashvilledatacleaning add propertysplitaddress varchar(255);
update nashvilledatacleaning set propertysplitaddress = substring(propertyaddress,1, Locate(',',propertyaddress)-1);
alter table nashvilledatacleaning add propertysplitcity varchar(255);
update nashvilledatacleaning set propertysplitcity = substring(propertyaddress, Locate(',',propertyaddress)+1, length(propertyaddress));

select owneraddress from nashvilledatacleaning;
select substring(owneraddress,1, Locate(',',owneraddress)-1) as owneraddress, substring(owneraddress, Locate(',',owneraddress)+1, length(owneraddress)) as ownercity,
substring(owneraddress, locate(',',owneraddress)+1) as ownerstate
from nashvilledatacleaning;
select substring_index(owneraddress,',',1) as owneraddress, substring_index((substring_index(owneraddress,',',2)),',',-1) as ownercity,
substring_index((substring_index(owneraddress,',',3)),',',-1) as ownerstate
from nashvilledatacleaning;
alter table nashvilledatacleaning add ownersplitaddress varchar(255);
update nashvilledatacleaning set ownersplitaddress = substring_index(owneraddress,',',1);
alter table nashvilledatacleaning add ownersplitcity varchar(255);
update nashvilledatacleaning set ownersplitcity = substring_index((substring_index(owneraddress,',',2)),',',-1);
alter table nashvilledatacleaning add ownersplitstate varchar(255);
update nashvilledatacleaning set ownersplitstate = substring_index((substring_index(owneraddress,',',3)),',',-1);

#changing Y and N to Yes and No
select distinct(soldasvacant),count(soldasvacant) from nashvilledatacleaning group by soldasvacant order by 2;
select soldasvacant,case when soldasvacant = 'Y' then 'Yes' when soldasvacant='N' then 'No' else soldasvacant end from nashvilledatacleaning;
update nashvilledatacleaning set soldasvacant = case when soldasvacant = 'Y' then 'Yes' when soldasvacant='N' then 'No' else soldasvacant end;

#deleting duplicates
WITH rownumcte as (select*, ROW_NUMBER()over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by ï»¿UniqueID) row_num 
from nashvilledatacleaning) select * from rownumcte where row_num>1 order by propertyaddress;
WITH rownumcte as (select*, ROW_NUMBER()over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by ï»¿UniqueID) row_num 
from nashvilledatacleaning) DELETE FROM nashvilledatacleaning USING nashvilledatacleaning JOIN rownumcte 
ON nashvilledatacleaning.ï»¿UniqueID = rownumcte.ï»¿UniqueID WHERE rownumcte.row_num > 1;

#deleting unused columns
alter table nashvilledatacleaning drop column propertyaddress,drop owneraddress,drop taxdistrict;