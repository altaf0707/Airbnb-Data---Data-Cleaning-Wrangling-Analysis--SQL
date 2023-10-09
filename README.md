# Airbnb Data Analysis with MySQL

## Project Overview

Explore Airbnb data for New York City using MySQL. Clean, transform, and analyze data to uncover insights.

## Scenario

Join a European boutique hotel company's expansion into New York City. They aim to establish a home accommodation network, targeting business travelers and corporate clients seeking value and proximity to commercial areas.

## Table of Contents

- [Project Overview](#project-overview)
- [Scenario](#scenario)
- [Table of Contents](#table-of-contents)
- [Tasks Completed](#tasks-completed)
- [Data Source](#data-source)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Tasks Completed

Summary of MySQL tasks:

### Data Preparation and Cleaning

- Created MySQL database and table for Airbnb data.
- Loaded CSV data into the database.
- Handled missing values appropriately.
- Standardized borough names (e.g., 'Brookly' to 'Brooklyn').

### Data Transformation

- Categorized room types based on price.
- Managed price outliers using IQR.
- Calculated property counts and average prices for boroughs and neighborhoods.
- Determined the most common room type.

### Data Analysis

- Identified high housing stock areas for home rentals.
- Analyzed price variations and found the most expensive borough.
- Explored revenue generation and average revenue per unit.
- Investigated availability differences among boroughs.
- Identified hosts with multiple properties.


## Usage

1. Set up a MySQL database.
2. Load CSV data into the database.
3. Execute code from the `Code` section in your MySQL client.
4. Customize database and table names as needed.

   
## Data Source

Data sourced from Airbnb listings in NYC, stored in a CSV file, includes property, host, pricing, and availability details.

## Data Dictionary

| Attribute           | Definition                                            |
| ------------------- | ---------------------------------------------------- |
| id                  | Unique ID for a residential listing                   |
| name                | A descriptive name for a listing                      |
| host_id             | A unique ID for the owner/host of a residence         |
| host_name           | Name of the owner/host of a residence                  |
| borough             | One of the five boroughs in New York City              |
| neighborhood        | A geographic subdivision of the boroughs               |
| latitude            | One of the coordinates for a residence                 |
| longitude           | The other coordinate for the residence                 |
| room_type           | A type of residence                                    |
| price               | Price per night in US dollars                         |
| minimum_nights      | Minimum number of nights for which one must rent a residence |
| last_review         | Latest review for a residence                           |
| reviews_per_month   | Average number of customer reviews per month           |
| availability_365    | Number of days a property is available in a year        |




## Data Assumptions

1. All units in the dataset are residential units.
2. Price is considered equivalent to revenue.
3. Assumptions are made to answer business questions with data storytelling.
4. Geopy module installation code is included for convenience.
5. We've answered more than 5 questions; explore both Tableau and the presentation for insights.


## Scope

1. Applicable only to the state of New York due to data limitations.
2. Focus on residential units listed on Airbnb.

## Limitations

1. Insights are subject to Airbnb data limitations.
2. Handling missing values and outliers may have slight inaccuracies.
3. Assumptions made due to limited data on residential and commercial units.


## Contributing

Contributions welcome! Open issues or pull requests for improvements or new analyses.

## License

This project is MIT licensed. See [LICENSE](LICENSE) for details.
