create database Portfolio_Project;
show databases;
use portfolio_project;
show tables;
select * from coviddeaths;
select * from covidvaccinations;
drop database portfolio_project;
truncate table covidvaccinations;
truncate table coviddeaths;
describe covidvaccinations;
describe coviddeaths;
select* from coviddeaths where continent is not null order by 3,4;

show global variables; 
set global local_infile=1;
load data local infile 'D:\\porfolio creation files\\Covid Deaths with null.csv' into table coviddeaths fields terminated by ',' ENCLOSED BY '"' Lines terminated by '\r\n' Ignore 1 lines;
load data local infile 'D:\\porfolio creation files\\Covid Vaccinations with null.csv' into table covidvaccinations 
fields terminated by ',' ENCLOSED BY '"' Lines terminated by '\r\n' Ignore 1 lines;

select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1,2;

# Looking at Total Cases vs Total Deaths
#shows likelihood of dying if contracted covid in Malaysia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from coviddeaths where location ="Malaysia" order by 1,2;

# Looking at Total Cases vs Population
#shows what percentage of population has contracted covid in Malaysia
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage from coviddeaths where location ="Malaysia" order by 1,2;

#Looking at countries with highest infection rate compared to population
#Shows percentage of total infection per country
select location, MAX(total_cases) as highestinfection, population, MAX((total_cases/population))*100 as InfectedPopulation 
from coviddeaths group by location, population order by InfectedPopulation desc;

#Shows highest death count per population
select location, max(cast(total_deaths as unsigned)) as totaldeathcount from coviddeaths where continent is not null group by location order by totaldeathcount desc;

#Shows deathcount per continent
select continent, MAX(cast(total_deaths as unsigned)) as highestdeaths from coviddeaths where continent is not null group by continent order by highestdeaths desc;

#Global numbers
select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned))as total_deaths, (Sum(cast(new_deaths as unsigned))/Sum(new_cases))*100 as DeathPercentage 
from coviddeaths where continent is not null group by date order by 1,2;
select Sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned))as total_deaths, (Sum(cast(new_deaths as unsigned))/Sum(new_cases))*100 as DeathPercentage 
from coviddeaths where continent is not null order by 1,2;

# Joins
Select * from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date;

#Vaccinations vs Total Population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null order by 2,3;
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location, dea.date) as rollingtotal
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null order by 2,3;
#CTE
with PopvsVac(Continent,location,date,population,new_vaccinations, rollingtotal) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location, dea.date) as rollingtotal
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)
Select *, (rollingtotal/population)*100 from PopvsVac;
#Temp Table
drop temporary table PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated
(Continent varchar(255),location varchar(255),date datetime,population varchar(255),new_vaccinations int, rollingtotal bigint);
insert into PercentPopulationVaccinated Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location, dea.date) as rollingtotal
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date;
Select *, (rollingtotal/population)*100 from PercentPopulationVaccinated;

#creating view to store data for later visualitations
create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as unsigned)) over(partition by dea.location order by dea.location, dea.date) as rollingtotal
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null;
