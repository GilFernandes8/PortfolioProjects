SELECT * from public.deaths
WHERE continent is not null

-- data selection
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM public.deaths
WHERE location = 'Portugal'
ORDER by 2

-- looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS lethality
FROM public.deaths
WHERE location = 'Portugal'
ORDER by 2

--looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS transmissibility
FROM public.deaths
WHERE location = 'Portugal'
ORDER by 2

--looking at total cases vs population per country

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS transmissibility
FROM public.deaths
WHERE continent is not null and total_deaths is not null
GROUP by location, population
ORDER by 4 DESC

--looking at deaths vs population per country

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, MAX((total_deaths/population))*100 AS lethality
FROM public.deaths
WHERE continent is not null and total_deaths is not null
GROUP by location, population
ORDER by TotalDeathCount DESC

--looking at deaths per continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM public.deaths
WHERE continent is null
GROUP by location
ORDER by TotalDeathCount DESC

--GLOBAL numbers
SELECT location,date, total_deaths as deaths, total_cases as cases
FROM public.deaths
WHERE location = 'World'
ORDER by date

SELECT location, MAX(total_deaths) as deaths, MAX(total_cases) as cases
FROM public.deaths
WHERE location = 'World'
GROUP by location



--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVac
FROM public.vaccination vac
Join public.deaths dea
	On dea.location = vac.location AND dea.date = vac.date
WHERE continent is not null
order by 2,3

--CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVac
FROM public.vaccination vac
Join public.deaths dea
	On dea.location = vac.location AND dea.date = vac.date
WHERE continent is not null
)
SELECT *, (RollingPeopleVac/population)*100
FROM PopvsVac


--temp table

Create TEMP Table PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVac numeric
)

INSERT INTO PercentPopulationVaccinated
VALUES (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVac
FROM public.vaccination vac
Join public.deaths dea
	On dea.location = vac.location AND dea.date = vac.date
WHERE continent is not null
)
	
	
	
	
SELECT *, (RollingPeopleVac/population)*100
FROM PercentPopulationVaccinated