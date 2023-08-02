--SELECT *
--FROM Portfolioproject..CovidDeaths
--Where continent is NULL
--ORDER BY 3,4

----SELECT *
----FROM Portfolioproject..CovidVaccinations 
----ORDER BY 3,4

--SELECT location,date,total_cases, new_cases,total_deaths,population
--FROM Portfolioproject..CovidDeaths
--ORDER BY 1,2

--Total cases vs total deaths
--Likelihood of dying if you contract covid in your country
--SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases )* 100 as DeathPercentage
--FROM Portfolioproject..CovidDeaths
--Where location like '%Kingdom%'
--Where continent is NOT NULL
--ORDER BY 1,2

----Looking at total cases and population
--SELECT location,date, population, total_cases, (total_cases/population )* 100 as PopulationInfectedPercentage
--FROM Portfolioproject..CovidDeaths
--Where location like '%Kingdom%'
--Where continent is NOT NULL
--ORDER BY 1,2

----Countries with highest Infection Rate comapred to Population

--SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population ))* 100 as PopulationInfectedPercentage
--FROM Portfolioproject..CovidDeaths
----Where location like '%Kingdom%'
--Where continent is NOT NULL
--GROUP BY location, population
--ORDER BY 4 DESC
 
-- --added continent
--SELECT continent, location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population ))* 100 as PopulationInfectedPercentage
--FROM Portfolioproject..CovidDeaths
----Where location like '%Kingdom%'
--Where continent is NOT NULL
--GROUP BY continent, location, population
--ORDER BY 1,4 DESC

----Countries highest death count per population
--SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Portfolioproject..CovidDeaths
----Where location like '%Kingdom%
--Where continent is NOT NULL
--GROUP BY location, population
--ORDER BY TotalDeathCount DESC

----Lets BREAK THINGS DOWN BY CONTINENT not correct
--SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Portfolioproject..CovidDeaths
----Where location like '%Kingdom%
--Where continent is NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--SELECT *
--FROM Portfolioproject..CovidDeaths
--ORDER By 4


----GLOBAL NUMBERS
--SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int))as Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)) *100 as GlobalDeathPercentage
--FROM Portfolioproject..CovidDeaths
--Where continent is NOT NULL
--GROUP BY date -- can remove this to get total 
--ORDER BY 1,2

--Looking at total population and vaccination
--Rolling count 
--Convert(int,-----) instead of cast
--SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
--,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,
--FROM Portfolioproject..CovidDeaths dea
--Join Portfolioproject..CovidVaccinations vac
-- ON dea.location = vac.location
-- and dea.date = vac.date
-- Where dea.continent is NOT NULL
--ORDER BY 2,3

--Using CTE
With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulation
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is NOT NULL

 SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulation
From #PercentPopulationVaccinated
ORDER BY 2,3

--Creating view to store data for later visulisation
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is NOT NULL

Select*
From PercentPopulationVaccinated
