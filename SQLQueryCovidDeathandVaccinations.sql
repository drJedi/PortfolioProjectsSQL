select location, date,continent, total_cases, new_cases, total_deaths, population 
from PortfolioDatabase..CovidDeath
--where continent is not null
order by 1,2

--Looking at total Cases vs total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioDatabase..CovidDeath
where location like '%poland%'and
continent is not null
order by 1,2

--looking at total_cases vs Population
--showing what percentage of population got covid

select location, date, population,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioDatabase..CovidDeath
where location like '%poland%'
order by 1,2

--Looking at countreis with highest infeciont Rate compare to population

select location, population,MAX(total_cases) as highestInfecionRate , Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioDatabase..CovidDeath
--where location like '%poland%'
group by location, population
order by PercentagePopulationInfected desc

--showing countries with Heighest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioDatabase..CovidDeath
--where location like '%poland%'
where continent is not null
group by location 
order by TotalDeathCount desc

--By the continent
--showing Continacne with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from PortfolioDatabase..CovidDeath
--where location like '%poland%'
where continent is null
group by location 
order by TotalDeathCount desc

--Global number
--check few opitons to avoid warning divid by 0:
set arithabort On
set ansi_warnings on
--try use CASE statment fucion:
select SUM(cast (new_cases as float)) as NewCases , SUM(cast(new_deaths as float)) as NewDeath,
case 
	WHEN SUM(cast((new_deaths) as float)) = 0 AND SUM(cast((new_cases) as float)) = 0 THEN NULL
	else SUM(cast((new_deaths) as float))/SUM(cast((new_cases) as float))*100
end as DeathPercentage
from PortfolioDatabase..CovidDeath 
where continent is not null 
--group by date
order by 1,2

--looking at total Population vs Vaccinations
--use CTE 
with PopVsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as float)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeath as dea
join PortfolioDatabase..CovidVacination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.location like '%poland%'
--order by 2,3 
)
select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac

--temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as float)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeath as dea
join PortfolioDatabase..CovidVacination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.location like '%poland%'
--order by 2,3 

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating View to store data  for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as float)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeath as dea
join PortfolioDatabase..CovidVacination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--and dea.location like '%poland%'
--order by 2,3 

--updating tables are not allow to work with
update CovidDeath
set new_deaths=''
where new_deaths=0.0
