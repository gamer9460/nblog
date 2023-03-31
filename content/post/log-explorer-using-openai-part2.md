---
title: "Log Explorer Using OpenAI - Part 2"
date: 2023-03-27T19:42:03+05:30
draft: false
tags: ["openai","nlp", "logging"]
categories: ["AI"]
image: "img/log-explorer-using-openai-part2.jpg"
author: "Bhupesh Varshney"
authorDes: "Software Developer at  Nurdsoft | Tech Writer |  Python & Golang"
authorUrl: "https://www.linkedin.com/in/bhupesh-v"
authorImage: "img/bhupesh-varshney.jpg"
---

In [part 1 of this blog post](https://www.pacenthink.io/post/log-explorer-using-openai-part-1/), we discussed the concept of using OpenAI to search logs through natural language. We explored different models and capabilities offered by OpenAI, specifically focusing on the Codex model and the code completion API.

In this blog post, we will delve deeper into the code completion API of GPT to determine its feasibility for our specific use case.

I have created various test tables to evaluate the performance of OpenAI in converting natural language to SQL queries within a log context.

## Limitations so far in converting prompt to SQL

- By default, OpenAI treats all fields as a string. So we need to define integer fields explicitly. In the below example, I removed data type int for `ResponseStatus`

  ```txt
  Prompt - 
  ### Postgres SQL tables, with their properties:
  # logs_table[message, msg, RequestHeaders.user_id, RequestHeaders.user_type, RequestMethod, RequestProxy, RequestTime, RequestURL, ResponseStatusCode, ResponseTime, time, level]
  ### A query to list messages having 5xx error
  SELECT

  Query Returned by OpenAI -
  SELECT * FROM logs_table WHERE ResponseStatusCode LIKE '5%'
  ```

- I tried to check if we can enforce a specific style inside the prompt. I noticed that we can enforce lower or uppercase but not any other casing style like camelcase etc.

  ```txt
  Prompt 1 - 
  ### Postgres SQL tables, with their properties:
  # logs_table[message, msg, RequestHeaders.user_id, RequestHeaders.user_type, RequestMethod, RequestProxy, RequestTime, RequestURL, ResponseStatusCode, ResponseTime, time, level]
  ### A query to list messages having errors
  SELECT

  Query Returned by OpenAI -
  SELECT * FROM logs_table WHERE level = 'error'

  Prompt 2 with uppercase of level field- 
  ### Postgres SQL tables, with their properties:
  # logs_table[message, msg, RequestHeaders.user_id, RequestHeaders.user_type, RequestMethod, RequestProxy, RequestTime, RequestURL, ResponseStatusCode, ResponseTime, time, level]
  # level(ERROR|DEBUG)
  ### A query to list messages having errors
  SELECT

  Query Returned by OpenAI -
  SELECT * FROM logs_table WHERE level = 'ERROR'

  Prompt 2 with Camelcase for level - 
  ### Postgres SQL tables, with their properties:
  # logs_table[message, msg, RequestHeaders.user_id, RequestHeaders.user_type, RequestMethod, RequestProxy, RequestTime, RequestURL, ResponseStatusCode, ResponseTime, time, level]
  # level(Error|Debug)
  ### A query to list messages having errors
  SELECT

  Query Returned by OpenAI -
  SELECT * FROM logs_table WHERE level = 'error'
  ```

- It can understand the context of provided fields in a schema for fairly simple & non-conflicting prompts and returns good results.

## Observations

1. Can Understand the meaning of each field in schema without giving any context. It mapped the 5xx error to the response status code.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### return top 10 logs from 2022 in worker app where it returned order not found error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name='worker' AND responseStatusCode=404 AND year=2022 LIMIT 10
   ```

2. Understood the meaning of error & mapped to status code without 200 errors.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### write query to return logs which had error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE responseStatusCode != 200
   ```

3. It correctly picks the relevant columns.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### write query to return logs where request was succesful in delhi for order endpoints. Only return endpoint & service name
   ```

   **Query Generated**

   ```sql
   SELECT requestUrl, app_name FROM logs_table WHERE responseStatusCode = 200 AND geoip.city_name = 'Delhi' AND requestUrl LIKE '%order%'
   ```

4. I added one more field URL in the schema before requestUrl in the schema definition. It always picks the first relevant field. There were 2 relevant fields for the endpoint -  url & requestUrl in the schema but it picked url because it comes first in the schema definition. But it returned request method instead of url.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,url,requestUrl,responseStatusCode(int)]

   ### write query to return logs where request was succesful in delhi for order endpoints. Only return endpoint & service name
   ```

   **Query Generated**

   ```sql
   SELECT RequestMethod, app_name FROM logs_table WHERE responseStatusCode = 200 AND geoip.city_name = 'Delhi' AND url LIKE '%order%'
   ```

5. Sometimes It gives unpredicted results for the same prompt. In the below example, for a few attempts it returned the query for the top 10 latest results, and in the rest of the attempts it didn’t have the order by & limit clause for the same prompt.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[message, msg, RequestHeaders.user_id, RequestHeaders.user_type, RequestMethod, RequestProxy, RequestTime, RequestURL, ResponseStatusCode, ResponseTime, time, level]
   
   ### A query to list messages having post request
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE  RequestMethod = 'POST'
   ORDER BY time DESC LIMIT 10
   ```

6. Schema is not followed for all prompts & it returns queries that contain fields that are not even present in the schema defined in the prompt.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]]

   ### return top 10 logs from 2022 in worker app where it returned order not found error
   SELECT
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name = 'worker' AND responseStatusCode = 404 AND year = 2022 LIMIT 10
   ```

## Unreliable Results

1. Schema not followed in this. Year columns don’t exist in the provided schema.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### return top 10 logs from 2022 in worker app where it returned order not found error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name='worker' AND responseStatusCode=404 AND year=2022 LIMIT 10
   ```

2. Changed the last query to Jan 2023, it started using order date column instead of the year which is a weird change but still added one extra clause for the get request method which is not the intent in the prompt.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]
   ### return top 10 logs from jan 2023 in worker app where it returned order not found error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name='worker' AND responseStatusCode=404 AND RequestMethod='GET' AND order_date >= '2023-01-01' AND order_date <= '2023-01-31' LIMIT 10
   ```

3. Added write query prefix to the previous query & it returned completely different results.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### write query to give top 10 logs from jan 2023 in worker app where it returned order not found error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name='worker' AND responseStatusCode=404 AND RequestMethod='GET' AND day_of_week_i=1 AND day_of_week='Monday' AND month_of_year='January' AND year=2023 LIMIT 10
   ```

4. Order not found error clause missing completely and just checking for all errors.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]

   ### write query to give top 10 logs from table in jan 2023 in worker app with order not found error
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE app_name='worker' AND level='ERROR' AND order_date BETWEEN '2023-01-01' AND '2023-01-31' LIMIT 10
   ```

5. A lot of unnecessary clauses on `app_name` & `category` and didn’t understand the context fully.

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:\n#
   # Table logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,requestUrl,responseStatusCode(int)]
   
   # return top 10 products where request returned order not found error. Return all product fields only for such orders
   ```

   **Query Generated**

   ```sql
   SELECT * FROM logs_table WHERE responseStatusCode = 404 AND RequestMethod = 'GET' AND app_name = 'orders' AND category = 'orders' AND level = 'ERROR' AND order_id IS NOT NULL AND products.product_id IS NOT NULL LIMIT 10
   ```

6. Prompt didn't specify to order & limit the results but still it did in the query

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,url,requestUrl,responseStatusCode(int), time]
   
   ### write query to return service names which were throwing 5xx error in last 15 mins
   ```

   **Query Generated**

   ```sql
   SELECT app_name, count(*) as count FROM logs_table WHERE responseStatusCode >= 500 AND time > now() - 15m GROUP BY app_name ORDER BY count DESC LIMIT 10
   ```

7. After I added service names in the previous prompt, it gave the intended results

   **Prompt**

   ```txt
   ### Postgres SQL tables, with their properties:
   # logs_table[RequestMethod,app_name,category,currency,customer_birth_date,customer_first_name,customer_full_name,customer_gender,customer_id,customer_last_name,customer_phone,day_of_week,day_of_week_i,email,geoip.city_name,geoip.continent_name,geoip.country_iso_code,geoip.location,geoip.region_name,level,manufacturer,order_date(datetime),order_id,products._id,products.base_price,products.base_unit_price,products.category,products.created_on,products.discount_amount,products.discount_percentage,products.manufacturer,products.min_price,products.price,products.product_id,products.product_name,products.quantity,products.sku,products.tax_amount,products.taxful_price,products.taxless_price,products.unit_discount_amount,url,requestUrl,responseStatusCode(int), time]
   ### write query to return service names only which were throwing 5xx error in last 15 mins
   ```

   **Query Generated**

   ```sql
   SELECT app_name FROM logs_table WHERE responseStatusCode >= 500 AND time > now() - 15m
   ```

## Pricing

OpenAI charges based on the number of tokens(1 token ~= 4 English char) and codex is in beta mode & free for now but we can take Davinci pricing for reference($0.02/1k tokens). Most real-world applications logs around at least 500-1000 fields & these fields need to be specified in every request to openAI which means openAI will charge $1 for around ~40-50 queries.

To reduce pricing, we need to find a way to define schema once only & execute prompts without schema so that no.of tokens will go down per request. The option of Fine-tuning the model is available but it is not yet available for codex so we can try this in the future once it is available. But I tried to train it on the davinci base model but it doesn’t work. A model can be fine-tuned like this

```sh
# submmitting data for fine-tuning 
openai api fine_tunes.create -t fine-tuned-data.jsonl -m davinci
```

The above command will enqueue the job for fine-tuning & once done it will return a new model id which can be used instead of the base model in any of the APIs

## Conclusion

On one hand, it is pretty impressive to see GPT converting any prompts to complex sql queries but it is not yet mature enough to be used directly in production-like environment without human intervention.
