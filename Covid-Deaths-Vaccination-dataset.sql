select * 
from CovidProject..CovidDeaths
Order by 3,4


select * 
from CovidProject..CovidVaccinations
Order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
Order by 1,2


--total_cases vs total_deaths and percentage of death based on contraction
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercenatge
from CovidProject..CovidDeaths
where location like 'India'
Order by 1,2


--total_cases vs population, and percentage of contraction based on population
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercenatge
from CovidProject..CovidDeaths
where location like 'India'
Order by 1,2


--highest infection rate cuntries based on population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationTnfection
from CovidProject..CovidDeaths
where continent is not null
group by location, population
Order by PercentPopulationTnfection desc

--highest death rate cuntries based on population
select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((cast(total_deaths as int)/population))*100 as PercentPopulationDeath
from CovidProject..CovidDeaths
where continent is not null
group by location, population
Order by PercentPopulationDeath desc


--as per continent the death rate
select location, max(cast(total_deaths as int)) as HighestDeathCount, max((cast(total_deaths as int)/population))*100 as PercentPopulationDeath
from CovidProject..CovidDeaths
where continent is null
group by location
Order by HighestDeathCount desc

--global number
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
from CovidProject..CovidDeaths
where continent is not null
group by date
Order by 1,2

select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
from CovidProject..CovidDeaths
where continent is not null
Order by 1,2


--join two tables
select * 
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date


--population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Rolling count of population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopvsVac ( continent, location, date, population, new_vaccination, RollingPeopleVaccination)
as
( select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccination/population)*100 VaccinationPercentagePerPopulation 
from PopvsVac


--using TEMP table
drop table if exists #PercentPopualtionVaccionated
create table #PercentPopualtionVaccionated
(contient nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric)

insert into #PercentPopualtionVaccionated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccination/population)*100 VaccinationPercentagePerPopulation 
from #PercentPopualtionVaccionated


--creating view to store date for visulization
create view PercentPopualtionVaccionated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopualtionVaccionated
