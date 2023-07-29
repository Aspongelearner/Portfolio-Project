Select * 
From dbo.CovidDeaths
Order by 3, 4

Select * 
From dbo.CovidVaccinations
Order by 3, 4


 --that is the data that i am going to use

Select Location, date, total_cases, new_cases, total_deaths,population
From dbo.CovidDeaths
Order by 1,2


 --total Cases VS total Deaths
 --Show the infection rate and death rate of Australia


Select Location, date, total_cases, total_deaths, (total_cases/population)*100 InfectionRate, (total_deaths/total_cases)*100 DeathRate
From dbo.CovidDeaths
Where location = 'Australia'
Order by 1, 2

 Find the country that got the highest infection rate compare to population  --Andorra

Select Location, population, MAX((total_cases/population)) InfectionRate, max(total_cases) infectioncount
From dbo.CovidDeaths
Group by location, population
Order by InfectionRate Desc

-- Find the countries with the highest death count per population

Select location, population, max(CAST(total_deaths as int)) highestDeath
From dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by  HighestDeath DESC

-- Show the continents information

Select continent, MAX(CAST(total_deaths as int)) highestDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by  HighestDeath DESC

--  the information base on the Global

Select Date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate  
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 

Select*
From PortfolioProject..CovidVaccinations

Select de.continent ,de.location, va.date, de.population, va.new_vaccinations
, sum(cast(va.new_vaccinations as int)) over(partition by de.location Order by de.location, de.date) TotalVacPopulation
From PortfolioProject..CovidVaccinations va
join PortfolioProject..CovidDeaths de
  on de.location = va.location and va.date=de.date
Where de.continent is not null
Order by 2,3,4

--Use CTE
With VacPop (continent, Location, date, population,new_vaccinations,TotalVacPopulation)
as
(
Select va.continent ,va.location, va.date, de.population, va.new_vaccinations
, sum(cast(va.new_vaccinations as int)) over(partition by de.location Order by de.location, de.date) TotalVacPopulation
From PortfolioProject..CovidVaccinations va
join PortfolioProject..CovidDeaths de
  on de.location = va.location and va.date=de.date
Where de.continent is not null

)

select *, TotalVacPopulation/population*100 as vacRate
From VacPop


-- use temptable

Drop table IF exists #tempTvacRate
Create Table #tempTvacRate
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
TotalVacPopulation numeric
)

Insert into #tempTvacRate
Select va.continent, va.location, va.date, de.population, va.new_vaccinations, sum(convert(int, va.new_vaccinations))over(partition by de.location Order by de.location, de.date) as TotalVacPopulation
From PortfolioProject..CovidVaccinations va
join PortfolioProject..CovidDeaths de
  on de.location = va.location and va.date=de.date


Select *, (TotalVacPopulation/population)*100 RateofVacc
From #tempTvacRate




