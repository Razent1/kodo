# Task 1
Before modeling any system to work with data, we need to understand a few things:
1) How all entities are arranged
2) How often is the data updated
3) How often does the data change, how often does the data schema change
4) The amount of data

For a long time, the Kimbal methodology prevailed in the field of building analytical data warehouses - building a data model based on the star schema

t. The star schema is popular in data warehousing because it optimizes performance for read-heavy analytical queries and is more intuitive for users to understand.

## Star Schema Design
In a star schema, we identify a central Fact table that contains measurable, quantitative data, and Dimension tables that contain descriptive attributes related to the fact data. For your e-commerce system, the Orders table naturally becomes the central Fact table, with modifications to include keys that link to Dimension tables.

I put sql code for star schema inside the file 'metadata_start.sql'. Also there are some examples of queries.
<img width="828" alt="Pasted Graphic" src="https://github.com/Razent1/kodo/assets/53121795/12fa2cca-3388-4dea-8b4a-2bf393febc43">


## Schema Adjustments
Normalization: While the star schema tends to denormalize data for analytical ease, certain attributes like payment and shipping information are kept in separate dimension tables due to their one-to-one relationship with orders. This slightly leans towards a snowflake schema but retains the star schema's simplicity for most analytical needs.

Date Dimension: This is crucial for any time-series analysis, allowing analysts to easily perform trend analysis without complex date functions on the fact table.

Customer and Address Dimensions: These are straightforward dimensions that describe who made the order and where it's going. In a typical star schema, you might denormalize the Address table into dim_customers and fact_orders. However, since both billing and shipping addresses are relevant, they are kept separate for flexibility.

## Benefits and Trade-offs
Benefits: The star schema simplifies analytical queries, making it easier for analysts to join fact data with dimensional context. It also improves query performance in many cases due to the simplified relationships.


Trade-offs: There's some redundancy, especially in the address information, which could lead to slightly increased storage requirements. Additionally, updates to dimensional data (like changing an address) need careful handling to maintain historical accuracy in the fact table.
Moreover, altering the schema (e.g., adding new dimensions or changing the granularity of the fact table) can be challenging and may require significant redesign or data migration efforts. And also, there's a tendency for data duplication, especially in dimension tables where attributes like names or addresses may be repeated across rows. This can lead to increased storage requirements and potential issues with data consistency.

Therefore, more and more often, when designing systems that use entities from the real world, engineers began to come to the data vault, developed by Dan Linstedt or the Anchor Model, developed by Lars Ronebak. These methodologies solve many problems related to data changes and their historicity. One of their main drawbacks is the complexity of the implementation of the model. It is necessary to model all the entities of this system well. In this assignment, I would like to implement the Anchor Model and tell you about it in a little more detail.

## Anchor Model
Data Vault/Anchor Modeling allows you to simulate reality. First of all, objects of the real world (people, cars, goods) and not quite real (receipts, email messages, IP addresses). At first, I wanted to list all these objects as objects of the real world, but I thought that this might confuse someone, so the email messages went into a separate subcategory, although for me, as for Data Vault/Anchor Modeling, they are all the same objects of the same real world that swallowed digital reality.In Data Vault, objects are mapped to tables of the Hub type, in Anchor Modeling to a table of the Anchor type.
Tables in Anchor Model should be in 6th normal form.

Implementing a full Anchor Model for the e-commerce system as described requires creating a series of tables that represent each entity (anchors), their attributes, and the ties between them. The file with this implementation stores in the file 'metadata_anchor.sql'
<img width="872" alt="Pasted Graphic 1" src="https://github.com/Razent1/kodo/assets/53121795/3bea67b5-29f1-4a4a-931d-047fdc5dfb77">
<img width="892" alt="Pasted Graphic 2" src="https://github.com/Razent1/kodo/assets/53121795/37752214-e981-4036-8f1e-92104a05d5a8">


Note:
Auto-incrementing IDs: These are used here for simplicity. Depending on your database system, you might use sequences or other mechanisms to generate unique identifiers.

Temporal Validity: valid_from and valid_to columns are used to track the historical validity of each attribute or tie, allowing for time-travel queries.


In the query examples provided, you can see and confirm that the number of joins has increased compared to a star schema. This is accurate, but experience has shown that analysts often don't need a large number of attributes for analysis. In fact, if there are a lot of attributes in a table, analysts can become confused about their purpose.

## Small design conclusion 

The star schema and the Anchor Model are designed with different goals in mind, and each has its advantages and disadvantages depending on the specific needs of a data warehouse or analytical system. Here's a comparison focusing on the disadvantages of the star schema when compared to the Anchor Model:

Star Schema Disadvantages Compared to the Anchor Model
Historical Data Handling:

Star Schema: It typically captures the state of the data at the time of loading into the warehouse. While slowly changing dimensions (SCD) techniques can be used to track historical changes, they can complicate the design and increase the complexity of queries.
Anchor Model: Designed inherently to manage historical data changes efficiently, allowing for easy tracking of how data attributes change over time without complicating the schema.
Schema Rigidity:

Star Schema: Altering the schema (e.g., adding new dimensions or changing the granularity of the fact table) can be challenging and may require significant redesign or data migration efforts.
Anchor Model: Offers a highly flexible schema that can easily accommodate changes. New attributes or relationships can be added without disrupting existing data structures, making it more adaptable to evolving data requirements.
Complexity in Capturing Many-to-Many Relationships:

Star Schema: Many-to-many relationships often require the introduction of bridge tables or complex query logic, which can complicate the schema and query design.
Anchor Model: Naturally accommodates many-to-many relationships through its design principles, allowing for more straightforward representation and querying of these relationships.
Data Duplication:

Star Schema: There's a tendency for data duplication, especially in dimension tables where attributes like names or addresses may be repeated across rows. This can lead to increased storage requirements and potential issues with data consistency.
Anchor Model: Minimizes data duplication through its normalization approach. Each piece of information is stored only once, reducing storage needs and improving consistency.
Query Performance and Complexity:

Star Schema: Optimized for query performance with denormalized tables that reduce the number of joins needed. However, for complex historical queries or when dealing with slowly changing dimensions, query complexity and performance can suffer.
Anchor Model: While it excels in handling historical queries and schema flexibility, the highly normalized structure means queries can become more complex and may involve multiple joins, potentially impacting performance.
Ease of Use:

Star Schema: Generally considered more straightforward for end-users and analysts to understand and query, due to its simplified and denormalized structure.
Anchor Model: The model's complexity and the abstraction of data into separate tables for each attribute and tie can make it more challenging for users not familiar with its design principles.

# Task 2
At my previous job, I created an original data quality checking tool. Using a user-friendly interface (UI) and backend service, users could log in, create a data check for several metrics, and manually review duplicates, data outliers, relevance, missing data, and other issues. After creating a check, the system automatically sent it for review according to a schedule. All checks were organized on a single dashboard, making it easy for users to monitor progress. If a data issue was detected, the system would automatically notify users via Slack and create a task in Jira for further review. By request I can share a project on GitHub

Therefore, to answer the first question, I can say that, in order to check the quality of data, we need to do the following: 
1) Establish an integrated and automated process for verifying data. As a tool, you can utilize the open-source Python library "great expectations". 
2) We have also conducted checks using sources, which is a technique called "Cross-Validation".
3) Regularly conduct data profiling to understand the data's characteristics, such as distributions, min/max values, and unique counts. This helps identify data quality issues like outliers, missing values, or unexpected duplicates.
4) Regular Data Audits: Periodically, perform manual audits of the data, especially focusing on critical data fields. This can involve sampling data records and reviewing them for accuracy and consistency.

Answering your second question, it is possible to detect anomalies in data by using the following techniques:

1) Use the necessary statistical metrics to verify the data (Z score etc..)
2) You need to make metrics on the complex relevance of the data, see the data profile
3) Implement unsupervised learning algorithms (e.g., anomaly detection models) that can learn from the data and identify patterns or data points that don't fit the established patterns. In my current company, we were just dealing with this issue in order to understand the clarity of payments in our payment system
4) Implementation of Data Lineage. If an organization has good data tracking in place, it can predict at which stage the anomaly will arise. To implement such a system, an open-source tool called DataHub can be used.

Question 3:

1) One of the main problems with this data is the lack of historical fields (deltas). Historical traceability must be present in the data
2) The Address table serves both shipping and billing purposes but doesn't differentiate between the two, which might complicate scenarios where customers use different addresses for shipping and billing.
3) These tables are not in third normal form. This can be seen in the examples of Orders, Customers, and Address tables. The "Company" field in Orders is not dependent on the primary key, as is the "currency" field in the Orders table or the "name" field in the Address table.Data redundancy at this level can lead to problems
