# Query code and execution:

**NLQ1:**
```
SELECT 
    l.city,
    -- Step 3: Determining price category dynamically using the library code structure
   CASE 
WHEN (ai.ollama_embed('mxbai-embed-large', 'cheap', host =>    'http://pgai-ollama:11434')::vector <=> ol.review_embedded) <         (ai.ollama_embed('mxbai-embed-large', 'fair', host => 'http://pgai-ollama:11434')::vector <=> ol.review_embedded)
                     AND 
 (ai.ollama_embed('mxbai-embed-large', 'cheap', host => 'http://pgai-ollama:11434')::vector <=> ol.review_embedded) <          (ai.ollama_embed('mxbai-embed-large', 'expensive', host => 'http://pgai-ollama:11434')::vector <=> ol.review_embedded)
                THEN 'cheap'
 WHEN (ai.ollama_embed('mxbai-embed-large', 'fair', host => 'http://pgai-ollama:11434')::vector <=> ol.review_embedded) <                      (ai.ollama_embed('mxbai-embed-large', 'expensive', host => 'http://pgai-ollama:11434')::vector <=> ol.review_embedded)
                THEN 'fair'
                ELSE 'expensive'
        END AS price_category,
    -- Finalizing Q with requested aggregation operators and physical attributes
   AVG(ol.unit_price) AS average_unit_price,
    SUM(ol.quantity) AS total_quantity_ordered

FROM order_Line ol
JOIN location l ON ol.restaurant_id = l.restaurant_id
JOIN time t ON ol.date_id = t.date_id

WHERE 
    t.month = 'March' 
    AND t.year = 2025

GROUP BY 
    l.city,
    price_category;
```
    
![Query Output](q1.png)


=========================================================================================================

**NLQ2:**
```
SELECT 
    t.year,
    ol.restaurant_id,
     -- Step 3: AI-based Text Aggregation Operator (Summarization-text code injected exactly)
    (ai.openai_chat_complete(
        'llama-3.1-8b-instant',
        jsonb_build_array(
            jsonb_build_object(
                'role', 'user', 
                'content', 'give me one line summary ' || STRING_AGG(ol.review, ', ')
            )
        )
    )->'choices'->0->'message'->>'content' )::text AS customer_reviews_summary

FROM order_Line ol
JOIN time t ON ol.date_id = t.date_id

WHERE 
    -- Filtering physical constraints
    t.month = 'March' 
    AND t.year = 2025

GROUP BY 
    t.year,
    ol.restaurant_id;'''
```
    
![Query Output](q2.png)

=========================================================================================================

 **NLQ3:**
```
SELECT 
    t.month,
    -- Finalizing Q with requested physical counts
    COUNT(DISTINCT ol.order_id) AS number_of_orders

FROM order_Line ol
JOIN time t ON ol.date_id = t.date_id
JOIN location l ON ol.restaurant_id = l.restaurant_id

WHERE 
    -- Step 3: Image filtering using the Image Embedding Similarity library code exactly
    ai.ollama_embed(
        'nomic-embed-text',
        'terrace',
        host => 'http://pgai-ollama:11434'
    )::vector <=> l.restaurant_picture_embedded < 0.4

GROUP BY t.month;
```


 ![Query Output](q3.png)


=========================================================================================================

 **NLQ4:**

```
WITH Restaurant_Continent_Lookup AS (
    SELECT 
        restaurant_id,
        country,
        COALESCE(
            (REGEXP_MATCH(
                (ai.openai_chat_complete(
                    'llama-3.1-8b-instant', 
                    jsonb_build_array(
                        jsonb_build_object(
                            'role', 'user', 
                            'content', 'Identify the continent for the country' || country
                        )
                    )
                )->'choices'->0->'message'->>'content')::text, 
                '[a-zA-Z\s]+'
            ))[1],
            'Unknown' 
        )::text AS virtual_continent
    FROM (
        SELECT DISTINCT restaurant_id, country FROM location
    ) AS unique_locations
)
SELECT 
    rcl.virtual_continent,
    t.month,
    AVG(ol.quantity) AS average_quantity_ordered
FROM order_Line ol
JOIN time t ON ol.date_id = t.date_id
JOIN Restaurant_Continent_Lookup rcl ON ol.restaurant_id = rcl.restaurant_id
GROUP BY 
    rcl.virtual_continent,
    t.month;
```

![Query Output](q4.png)
     
=========================================================================================================

 **NLQ5:**

```
SELECT 
    ol.restaurant_id,
    -- Finalizing Q with requested physical aggregation operator
    SUM(ol.amount) AS total_amount_spent

FROM order_Line ol

WHERE 
    -- Step 3: Filtering using the Text Embedding Similarity library code exactly
    ai.ollama_embed(
        'mxbai-embed-large',
        'expensive',
        host => 'http://pgai-ollama:11434'
    )::vector <=> ol.review_embedded < 0.4

GROUP BY 
    ol.restaurant_id;
```

![Query Output](q5.png)


=========================================================================================================

 **NLQ6:**

```
SELECT 
    -- Finalizing Q with requested physical aggregation operator
    SUM(ol.quantity) AS total_quantity

FROM order_Line ol
JOIN time t ON ol.date_id = t.date_id
JOIN dish d ON ol.dish_id = d.dish_id
JOIN location l ON ol.restaurant_id = l.restaurant_id

WHERE 
    -- Filtering physical constraints
    t.year = 2025
    AND d.dish_name = 'Burger'
       -- Step 3: Text filtering using the Text Embedding Similarity library code exactly
    AND ai.ollama_embed(
        'mxbai-embed-large',
        'romantic',
        host => 'http://pgai-ollama:11434'
    )::vector <=> l.restaurant_description_embedded < 0.4;
```
  ![Query Output](q6.png)



  =========================================================================================================


   **NLQ7:**
```
SELECT 
    ol.restaurant_id,
    -- Finalizing Q with requested physical aggregation operator
    AVG(ol.unit_price) AS average_price

FROM order_Line ol
JOIN dish d ON ol.dish_id = d.dish_id

WHERE 
    -- Filtering physical constraints
    d.dish_name = 'Pizza'
    -- Evaluating if the picture taken by the client is visually similar to the official picture
    -- Using the associated embedding columns and the distance threshold (< 0.4) established in the library
    AND ol.dish_picture_embedded <=> d.dish_picture_embedded < 0.4

GROUP BY 
    ol.restaurant_id;
```
  ![Query Output](q7.png)


=========================================================================================================


   **NLQ8:**

```
SELECT 
    -- Step 3: AI-based Text Aggregation Operator (Summarization-text code injected exactly)
    (ai.openai_chat_complete(
        'llama-3.1-8b-instant',
        jsonb_build_array(
            jsonb_build_object(
                'role', 'user', 
                'content', 'give me one line summary ' || STRING_AGG(l.restaurant_description, ', ')
            )
        )
    )->'choices'->0->'message'->>'content' )::text AS romantic_restaurants_summary

FROM location l

WHERE 
    -- Step 3: Text filtering using the Text Embedding Similarity library code exactly
    ai.ollama_embed(
        'mxbai-embed-large',
        'romantic',
        host => 'http://pgai-ollama:11434'
    )::vector <=> l.restaurant_description_embedded < 0.4;
```
![Query Output](q8.png)

=========================================================================================================

   **NLQ9:**

```
 WITH Restaurant_Continent_Lookup AS (
    SELECT 
        restaurant_id,
        country,     
        COALESCE(
            (REGEXP_MATCH(
                (ai.openai_chat_complete(
                    'llama-3.1-8b-instant', 
                    jsonb_build_array(
                        jsonb_build_object(
                            'role', 'user', 
                            'content', 'Identify the continent for the country:' || country
                        )
                    )
                )->'choices'->0->'message'->>'content')::text, 
                '[a-zA-Z\s]+'
            ))[1],
            'Unknown' 
        )::text AS virtual_continent
    FROM (
        -- Select unique countries linked to their restaurant IDs to avoid duplicate LLM invocations
        SELECT DISTINCT restaurant_id, country FROM location
    ) AS unique_locations
)
SELECT 
    rcl.virtual_continent,
    d.dish_name,  
    -- Finalizing Q with requested physical aggregation operator
    SUM(ol.quantity) AS total_quantity_ordered

FROM order_Line ol
JOIN dish d ON ol.dish_id = d.dish_id
JOIN Restaurant_Continent_Lookup rcl ON ol.restaurant_id = rcl.restaurant_id

WHERE 
    ai.ollama_embed(
        'mxbai-embed-large',
        'very expensive',
		 host => 'http://pgai-ollama:11434'
    )::vector <=> ol.review_embedded < 0.4

GROUP BY 
    rcl.virtual_continent,
    d.dish_name;
```
   ![Query Output](q9.png)


   ========================================================================================================= 

  **NLQ11:**


```
WITH OrderContext AS (
    SELECT ol.unit_price, l.country, d.dish_name, ol.order_id, ol.quantity, l.city
    FROM order_line ol
    JOIN location l ON ol.restaurant_id = l.restaurant_id
    JOIN dish d ON ol.dish_id = d.dish_id
    JOIN time t ON ol.date_id = t.date_id
    WHERE t.month = 'March' AND t.year = 2025
),
UniquePricePoints AS (
    SELECT DISTINCT dish_name, country, unit_price
    FROM OrderContext
),
PriceClassification AS (
    SELECT 
        dish_name, country, unit_price,
        (ai.openai_chat_complete(
            'llama-3.1-8b-instant',
            jsonb_build_array(
                jsonb_build_object(
                    'role', 'user', 
                    'content', format('Classify price as "cheap", "expensive", or "fair" for %s in %s. Price: %s. Respond with one word.', dish_name, country, unit_price)
                )
            )
        )->'choices'->0->'message'->>'content')::text AS raw_category
    FROM UniquePricePoints
)
SELECT 
    oc.city,
    NULLIF(REGEXP_REPLACE(LOWER(pc.raw_category), '[^a-z]+', '', 'g'), '') AS price_category,
    AVG(oc.unit_price) AS average_unit_price,
    SUM(oc.quantity) AS total_quantity_ordered
FROM OrderContext oc
JOIN PriceClassification pc 
  ON oc.dish_name = pc.dish_name 
 AND oc.country = pc.country 
 AND oc.unit_price = pc.unit_price
GROUP BY oc.city, price_category;
```
![Query Output](q11.png)


   ========================================================================================================= 

 **NLQ12:**

```
SELECT 
    -- Step 3: Applying Image Embedding Similarity library code conditionally to derive the virtual level
    CASE 
        WHEN ai.ollama_embed(
            'nomic-embed-text',
            'outdoor',
            host => 'http://pgai-ollama:11434'
        )::vector <=> l.restaurant_picture_embedded < 0.4 THEN 'outdoor'
        ELSE 'indoor'
    END AS restaurant_type,  
    -- Finalizing Q with remaining physical aggregation operator
    AVG(ol.unit_price) AS average_unit_price

FROM order_Line ol
JOIN location l ON ol.restaurant_id = l.restaurant_id

GROUP BY 
    restaurant_type;
```
   ![Query Output](q12.png)





   

========================================================================================================= 

# USER QUERIES

========================================================================================================= 

**Query:Find  the average number of orders for restaurants located close to the sea**





``` 
WITH sea_side_restaurants AS (
    SELECT 
        restaurant_id
    FROM 
        location
    WHERE 
        -- Applying the Text Embedding Similarity library function
        ai.ollama_embed(
            'mxbai-embed-large',
            'close to the sea',
            host => 'http://pgai-ollama:11434'
        )::vector <=> restaurant_description_embedded < 0.4
),
orders_per_restaurant AS (
    SELECT 
        o.restaurant_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM 
        order_Line o
    JOIN 
        sea_side_restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY 
        o.restaurant_id
)
SELECT 
    AVG(total_orders) AS average_orders_near_sea
FROM 
    orders_per_restaurant;
```


========================================================================================================= 



**Query:Find  the total quantity for cities having less than 50000 population**


``` 
WITH city_populations AS (
    SELECT DISTINCT
        city,
        -- Strict sanitization block applied to the LLM mathematical selection
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant', -- assuming standard library LLM model
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Return only the total population as a single number for the city of ' || city || '. Do not include any text or punctuation.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS population
    FROM 
        location
),
filtered_locations AS (
    SELECT 
        l.restaurant_id
    FROM 
        location l
    JOIN 
        city_populations cp ON l.city = cp.city
    WHERE 
        -- Preventing casting errors on empty responses via NULLIF
        NULLIF(cp.population, NULL) < 50000
)
SELECT 
    SUM(o.quantity) AS total_quantity
FROM 
    order_Line o
JOIN 
    filtered_locations fl ON o.restaurant_id = fl.restaurant_id;
```


========================================================================================================= 



**Query:Give me the average hamburger price**


``` 
WITH hamburger_lookup AS (
    SELECT 
        dish_id,
        -- Strict sanitization block applied to the LLM-driven selection
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze the dish name: ''' || dish_name || '''. Is this dish a hamburger or a variation of a hamburger? Reply with exactly ''1'' for yes and ''0'' for no. Do not include any other text or punctuation.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_hamburger
    FROM 
        dish
),
filtered_dishes AS (
    SELECT 
        dish_id
    FROM 
        hamburger_lookup
    WHERE 
        -- Filtering by our sanitized binary indicator while preventing empty string errors
        NULLIF(is_hamburger, NULL) = 1
)
SELECT 
    AVG(o.unit_price) AS average_hamburger_price
FROM 
    order_Line o
JOIN 
    filtered_dishes fd ON o.dish_id = fd.dish_id;
```



========================================================================================================= 



**Query:What is the difference in sales occurring during holidays and working days?**


``` 
WITH date_classification AS (
    SELECT 
        date_id,
        -- Strict sanitization block applied to the LLM temporal classification
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze this date information: Month is ''' || month || ''' and Year is ''' || year || '''. Is a generic day in this month and year typically considered a holiday month or a working period? Reply with exactly ''1'' if it leans heavily towards holiday seasons/vacation months or ''0'' if it is a standard working period. Reply with just the number.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_holiday
    FROM 
        time
),
sales_by_day_type AS (
    SELECT
        -- Protecting against empty responses using NULLIF before conditional evaluation
        CASE WHEN NULLIF(dc.is_holiday, NULL) = 1 THEN 'holiday' ELSE 'working' END AS day_type,
        SUM(o.amount) AS total_sales
    FROM 
        order_Line o
    JOIN 
        date_classification dc ON o.date_id = dc.date_id
    GROUP BY 
        CASE WHEN NULLIF(dc.is_holiday, NULL) = 1 THEN 'holiday' ELSE 'working' END
)
SELECT 
    COALESCE(SUM(CASE WHEN day_type = 'holiday' THEN total_sales END), 0) -
    COALESCE(SUM(CASE WHEN day_type = 'working' THEN total_sales END), 0) AS sales_difference
FROM 
    sales_by_day_type;
```


========================================================================================================= 


**Query:What is the difference in sales occurring during holidays and working days?**


``` 
WITH date_classification AS (
    SELECT 
        date_id,
        -- Strict sanitization block applied to the LLM temporal classification
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze this date information: Month is ''' || month || ''' and Year is ''' || year || '''. Is a generic day in this month and year typically considered a holiday month or a working period? Reply with exactly ''1'' if it leans heavily towards holiday seasons/vacation months or ''0'' if it is a standard working period. Reply with just the number.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_holiday
    FROM 
        time
),
sales_by_day_type AS (
    SELECT
        -- Protecting against empty responses using NULLIF before conditional evaluation
        CASE WHEN NULLIF(dc.is_holiday, NULL) = 1 THEN 'holiday' ELSE 'working' END AS day_type,
        SUM(o.amount) AS total_sales
    FROM 
        order_Line o
    JOIN 
        date_classification dc ON o.date_id = dc.date_id
    GROUP BY 
        CASE WHEN NULLIF(dc.is_holiday, NULL) = 1 THEN 'holiday' ELSE 'working' END
)
SELECT 
    COALESCE(SUM(CASE WHEN day_type = 'holiday' THEN total_sales END), 0) -
    COALESCE(SUM(CASE WHEN day_type = 'working' THEN total_sales END), 0) AS sales_difference
FROM 
    sales_by_day_type;
```


========================================================================================================= 


**Query:What is the average review for restaurants that do not sell fish?**


``` 
WITH fish_dishes AS (
    SELECT 
        dish_id,
        -- Strict sanitization block applied to the LLM-driven selection
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze the dish name: ''' || dish_name || '''. Is this dish made of fish, seafood, or does it contain fish? Reply with exactly ''1'' for yes and ''0'' for no. Do not include any other text or punctuation.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_fish
    FROM 
        dish
),
restaurants_selling_fish AS (
    SELECT DISTINCT
        o.restaurant_id
    FROM 
        order_Line o
    JOIN 
        fish_dishes fd ON o.dish_id = fd.dish_id
    WHERE 
        NULLIF(fd.is_fish, NULL) = 1
)
SELECT 
    -- Applying the Summarization-text library function as the aggregation operator
    (ai.openai_chat_complete(
        'llama-3.1-8b-instant',
        jsonb_build_array(
            jsonb_build_object(
                'role', 'user', 
                'content', 'give me one line summary' || STRING_AGG(o.review, ' ')
            )
        )
    )->'choices'->0->'message'->>'content' )::text AS average_review
FROM 
    order_Line o
WHERE 
    o.review IS NOT NULL
    -- Negation filter: Exclude restaurants that sell fish
    AND o.restaurant_id NOT IN (SELECT restaurant_id FROM restaurants_selling_fish);
```


========================================================================================================= 



**Query:What is the average review for restaurants grouped by the size of hamburgers?**


``` 
WITH hamburger_sizing AS (
    SELECT 
        dish_id,
        -- Applying sanitization and explicit text casting for grouping
        (ai.openai_chat_complete(
            'llama-3.1-8b-instant',
            jsonb_build_array(
                jsonb_build_object(
                    'role', 'user', 
                    'content', 'Analyze the dish name: ''' || dish_name || '''. If this dish is a hamburger, classify its size or portion type into one word (e.g., ''Small'', ''Regular'', ''Large'', ''Double''). If it is not a hamburger, reply with ''Not a Hamburger''. Do not include any other text or punctuation.'
                )
            )
        )->'choices'->0->'message'->>'content')::text AS hamburger_size
    FROM 
        dish
),
classified_orders AS (
    SELECT 
        o.review,
        hs.hamburger_size
    FROM 
        order_Line o
    JOIN 
        hamburger_sizing hs ON o.dish_id = hs.dish_id
    WHERE 
        -- Filtering out empty responses and non-hamburger records
        NULLIF(hs.hamburger_size, '') IS NOT NULL 
        AND hs.hamburger_size <> 'Not a Hamburger'
        AND o.review IS NOT NULL
)
SELECT 
    co.hamburger_size,
    -- Applying the Summarization-text library function as the aggregation operator
    (ai.openai_chat_complete(
        'llama-3.1-8b-instant',
        jsonb_build_array(
            jsonb_build_object(
                'role', 'user', 
                'content', 'give me one line summary' || STRING_AGG(co.review, ' ')
            )
        )
    )->'choices'->0->'message'->>'content')::text AS average_review
FROM 
    classified_orders co
GROUP BY 
    co.hamburger_size;
```


========================================================================================================= 


**Query:Compare the quantity of sales for restaurants in the seaside and the countryside**


``` 
WITH categorized_locations AS (
    SELECT 
        restaurant_id,
        CASE 
            WHEN (ai.ollama_embed(
                'mxbai-embed-large',
                'seaside',
                host => 'http://pgai-ollama:11434'
            )::vector <=> restaurant_description_embedded) < 0.4 THEN 'seaside'
            WHEN (ai.ollama_embed(
                'mxbai-embed-large',
                'countryside',
                host => 'http://pgai-ollama:11434'
            )::vector <=> restaurant_description_embedded) < 0.4 THEN 'countryside'
            ELSE 'other'
        END AS location_type
    FROM 
        location
),
group_quantities AS (
    SELECT
        cl.location_type,
        SUM(o.quantity) AS total_quantity
    FROM 
        order_Line o
    JOIN 
        categorized_locations cl ON o.restaurant_id = cl.restaurant_id
    WHERE 
        cl.location_type IN ('seaside', 'countryside')
    GROUP BY 
        cl.location_type
)
SELECT 
    COALESCE(SUM(CASE WHEN location_type = 'seaside' THEN total_quantity END), 0) AS seaside_total_quantity,
    COALESCE(SUM(CASE WHEN location_type = 'countryside' THEN total_quantity END), 0) AS countryside_total_quantity,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN location_type = 'seaside' THEN total_quantity END), 0) > 
             COALESCE(SUM(CASE WHEN location_type = 'countryside' THEN total_quantity END), 0) THEN 'Seaside has more sales quantity.'
        WHEN COALESCE(SUM(CASE WHEN location_type = 'seaside' THEN total_quantity END), 0) < 
             COALESCE(SUM(CASE WHEN location_type = 'countryside' THEN total_quantity END), 0) THEN 'Countryside has more sales quantity.'
        ELSE 'Both regions have equal sales quantity.'
    END AS comparison_result
FROM 
    group_quantities;
```


========================================================================================================= 


**Query:Are restaurants in the countryside more expensive than restaurants by the seaside?**


``` 
WITH categorized_locations AS (
    SELECT 
        restaurant_id,
        CASE 
            WHEN ai.ollama_embed(
                'mxbai-embed-large',
                'countryside',
                host => 'http://pgai-ollama:11434'
            )::vector <=> restaurant_description_embedded < 0.4 THEN 'countryside'
            WHEN ai.ollama_embed(
                'mxbai-embed-large',
                'seaside',
                host => 'http://pgai-ollama:11434'
            )::vector <=> restaurant_description_embedded < 0.4 THEN 'seaside'
            ELSE 'other'
        END AS location_type
    FROM 
        location
),
group_averages AS (
    SELECT
        cl.location_type,
        AVG(o.unit_price) AS average_price
    FROM 
        order_Line o
    JOIN 
        categorized_locations cl ON o.restaurant_id = cl.restaurant_id
    WHERE 
        cl.location_type IN ('countryside', 'seaside')
    GROUP BY 
        cl.location_type
)
SELECT 
    COALESCE(SUM(CASE WHEN location_type = 'countryside' THEN average_price END), 0) AS countryside_avg_price,
    COALESCE(SUM(CASE WHEN location_type = 'seaside' THEN average_price END), 0) AS seaside_avg_price,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN location_type = 'countryside' THEN average_price END), 0) > 
             COALESCE(SUM(CASE WHEN location_type = 'seaside' THEN average_price END), 0) THEN 'Yes, countryside is more expensive.'
        ELSE 'No, seaside is more expensive or equal.'
    END AS evaluation_result
FROM 
    group_averages;
```
========================================================================================================= 


**Query:For each continent, show me the average price of burgers on a monthly basis**


``` 
WITH continent_lookup AS (
    SELECT DISTINCT
        l.country,
        -- Virtual Level: continent (Enriched via LLM and explicitly cast to text)
        (ai.openai_chat_complete(
            'llama-3.1-8b-instant',
            jsonb_build_array(
                jsonb_build_object(
                    'role', 'user', 
                    'content', 'Identify the continent where the country ''' || l.country || ''' is located. Reply ONLY with the name of the continent as plain text.'
                )
            )
        )->'choices'->0->'message'->>'content')::text AS continent
    FROM 
        location l
)
SELECT 
    cl.continent,
    t.year,
    t.month,
    -- Aggregation: Average price of burgers
    AVG(ol.unit_price) AS average_burger_price
FROM 
    order_Line ol
JOIN 
    dish d ON ol.dish_id = d.dish_id
JOIN 
    time t ON ol.date_id = t.date_id
JOIN 
    location l ON ol.restaurant_id = l.restaurant_id
JOIN 
    continent_lookup cl ON l.country = cl.country
WHERE 
    -- Filter: Strictly target burger dishes
    d.dish_name ILIKE '%burger%'
GROUP BY 
    cl.continent,
    t.year,
    t.month
ORDER BY 
    cl.continent,
    t.year,
    t.month;
```

========================================================================================================= 


**Query:Group orders by customer satisfaction and tell me the average price and number of orders**


``` 
WITH review_satisfaction_mapping AS (
    SELECT 
        ol.order_id,
        ol.unit_price,
        ol.review,
        -- Virtual Level: customer_satisfaction (Enriched via LLM and explicitly cast to text)
        (ai.openai_chat_complete(
            'llama-3.1-8b-instant',
            jsonb_build_array(
                jsonb_build_object(
                    'role', 'user', 
                    'content', 'Analyze this restaurant customer review and classify the satisfaction level into one of these exact categories: ''High'', ''Medium'', or ''Low''. Reply only with the category name. Review: ' || ol.review
                )
            )
        )->'choices'->0->'message'->>'content')::text AS customer_satisfaction
    FROM 
        order_Line ol
    WHERE 
        ol.review IS NOT NULL 
        AND ol.review <> ''
)
SELECT 
    rsm.customer_satisfaction,
    -- Aggregation: Average price per satisfaction tier
    AVG(rsm.unit_price) AS average_price,
    -- Aggregation: Total distinct number of orders per tier
    COUNT(DISTINCT rsm.order_id) AS number_of_orders
FROM 
    review_satisfaction_mapping rsm
GROUP BY 
    rsm.customer_satisfaction
ORDER BY 
    CASE rsm.customer_satisfaction
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END;
```
========================================================================================================= 


**Query:Count, for every city and dish, the percentage of orders where the picture of the dish is close to the standard picture**


``` 
SELECT 
    l.city,
    d.dish_name,
    -- Aggregation: Total number of order lines for context
    COUNT(ol.order_id) AS total_order_lines,
    -- Aggregation: Percentage calculation using a conditional CASE statement
    ROUND(
        (COUNT(CASE WHEN (ol.dish_picture_embedded <=> d.dish_picture_embedded) < 0.4 THEN 1 END) * 100.0) 
        / COUNT(ol.order_id), 
        2
    ) AS percentage_close_to_standard
FROM 
    order_Line ol
JOIN 
    location l ON ol.restaurant_id = l.restaurant_id
JOIN 
    dish d ON ol.dish_id = d.dish_id
WHERE 
    ol.dish_picture_embedded IS NOT NULL 
    AND d.dish_picture_embedded IS NOT NULL
GROUP BY 
    l.city, 
    d.dish_name
ORDER BY 
    l.city, 
    percentage_close_to_standard DESC;
```
========================================================================================================= 


**Query:Tell me the percentage of restaurants per city where the review indicates the restaurants' description being inconsistent**


``` 
WITH review_consistency_check AS (
    SELECT 
        l.city,
        l.restaurant_id,
        -- Virtual Level: is_inconsistent (Value 1.0 = Yes, Value 0.0 = No)
        CAST(
            NULLIF(
                REGEXP_REPLACE(
                    (REGEXP_MATCH(
                        (ai.openai_chat_complete(
                            'llama-3.1-8b-instant',
                            jsonb_build_array(
                                jsonb_build_object(
                                    'role', 'user', 
                                    'content', 'Compare this restaurant description with a customer review. Does the review imply that the description is inaccurate, misleading, or inconsistent with reality? \nDescription: ' || l.restaurant_description || '\nReview: ' || ol.review || '\nReply ONLY with 1 for yes and 0 for no.'
                                )
                            )
                        )->'choices'->0->'message'->>'content')::text, 
                        '[0-9.]+'
                    ))[1], 
                    '[^0-9.]', 
                    '', 
                    'g'
                ), 
                ''
            ) AS DOUBLE PRECISION
        ) AS is_inconsistent
    FROM 
        location l
    JOIN 
        order_Line ol ON l.restaurant_id = ol.restaurant_id
    WHERE 
        ol.review IS NOT NULL 
        AND ol.review <> ''
        AND l.restaurant_description IS NOT NULL 
        AND l.restaurant_description <> ''
),
restaurant_flags AS (
    SELECT 
        city,
        restaurant_id,
        -- If any review flags an inconsistency, mark the restaurant as inconsistent (1)
        MAX(CASE WHEN is_inconsistent = 1.0 THEN 1 ELSE 0 END) AS restaurant_has_inconsistency
    FROM 
        review_consistency_check
    GROUP BY 
        city,
        restaurant_id
)
SELECT 
    city,
    COUNT(restaurant_id) AS total_restaurants,
    -- Aggregation: Percentage of distinct restaurants with an inconsistency flag
    ROUND(
        (SUM(restaurant_has_inconsistency) * 100.0) / COUNT(restaurant_id), 
        2
    ) AS percentage_inconsistent_restaurants
FROM 
    restaurant_flags
GROUP BY 
    city
ORDER BY 
    percentage_inconsistent_restaurants DESC, 
    city;
```
========================================================================================================= 


**Query: Tell me, for each continent and dish, the percentage of reviews indicating that the dish is cheap**


``` 
WITH continent_lookup AS (
    SELECT DISTINCT
        l.country,
        -- Virtual Level: continent (Enriched via LLM and cast to text)
        (ai.openai_chat_complete(
            'llama-3.1-8b-instant',
            jsonb_build_array(
                jsonb_build_object(
                    'role', 'user', 
                    'content', 'Identify the continent where the country ''' || l.country || ''' is located. Reply ONLY with the name of the continent as plain text.'
                )
            )
        )->'choices'->0->'message'->>'content')::text AS continent
    FROM 
        location l
)
SELECT 
    cl.continent,
    d.dish_name,
    COUNT(ol.order_id) AS total_reviews,
    -- Aggregation: Calculate percentage using vector distance threshold
    ROUND(
        (COUNT(
            CASE 
                WHEN (ol.review_embedded <=> ai.ollama_embed(
                    'mxbai-embed-large', 
                    'cheap', 
                    host => 'http://pgai-ollama:11434'
                )::vector) < 0.4 
                THEN 1 
            END
        ) * 100.0) / COUNT(ol.order_id), 
        2
    ) AS percentage_cheap_reviews
FROM 
    order_Line ol
JOIN 
    dish d ON ol.dish_id = d.dish_id
JOIN 
    location l ON ol.restaurant_id = l.restaurant_id
JOIN 
    continent_lookup cl ON l.country = cl.country
WHERE 
    ol.review_embedded IS NOT NULL
GROUP BY 
    cl.continent, 
    d.dish_name
ORDER BY 
    cl.continent, 
    percentage_cheap_reviews DESC, 
    d.dish_name;
```






========================================================================================================= 

# OPERATIONAL QUERIES

========================================================================================================= 

**Query:Where can I find the most authentic sushi in Paris?**


``` 
WITH sushi_classification AS (
    SELECT 
        dish_id,
        -- Strict sanitization block applied to the LLM-driven sushi classification
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze the dish name: ''' || dish_name || '''. Is this dish a traditional Japanese sushi, sashimi, or nigiri (excluding generic western fusion rolls unless specified as authentic)? Reply with exactly ''1'' for yes and ''0'' for no. Do not include any other text or punctuation.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_sushi
    FROM 
        dish
),
authentic_japanese_paris_restaurants AS (
    SELECT 
        restaurant_id,
        restaurant_description,
        -- Calculating semantic distance to "authentic Japanese restaurant" using pre-computed embeddings
        (ai.ollama_embed(
            'mxbai-embed-large',
            'authentic Japanese restaurant',
            host => 'http://pgai-ollama:11434'
        )::vector <=> restaurant_description_embedded) AS authenticity_distance
    FROM 
        location
    WHERE 
        LOWER(city) = 'paris'
        AND (ai.ollama_embed(
            'mxbai-embed-large',
            'authentic Japanese restaurant',
            host => 'http://pgai-ollama:11434'
        )::vector <=> restaurant_description_embedded) < 0.4
)
SELECT DISTINCT
    ajpr.restaurant_id,
    ajpr.restaurant_description,
    d.dish_name,
    o.unit_price,
    ajpr.authenticity_distance
FROM 
    order_Line o
JOIN 
    sushi_classification sc ON o.dish_id = sc.dish_id
JOIN 
    authentic_japanese_paris_restaurants ajpr ON o.restaurant_id = ajpr.restaurant_id
JOIN 
    dish d ON d.dish_id = o.dish_id
WHERE 
    NULLIF(sc.is_sushi, NULL) = 1
ORDER BY 
    ajpr.authenticity_distance ASC;
```



========================================================================================================= 

**Query:Find inexpensive restaurants**


``` 
SELECT 
    restaurant_id,
    restaurant_description,
    city,
    -- Calculate the cosine distance (smaller distance indicates higher semantic similarity)
    (ai.ollama_embed(
        'mxbai-embed-large',
        'inexpensive restaurant',
        host => 'http://pgai-ollama:11434'
    )::vector <=> restaurant_description_embedded) AS price_similarity_distance
FROM 
    location
WHERE 
    -- Filter out locations that do not semantically align with the cheap/budget concept
    (ai.ollama_embed(
        'mxbai-embed-large',
        'inexpensive restaurant',
        host => 'http://pgai-ollama:11434'
    )::vector <=> restaurant_description_embedded) < 0.4
ORDER BY 
    price_similarity_distance ASC;
```







========================================================================================================= 

# UNCONVENTIONAL/FUZZY EXPRESSIONS

========================================================================================================= 


**Query:What is the average price of a hamburger in Paris restaurants that are absolute tourist traps?**


``` 
WITH burger_classification AS (
    SELECT 
        dish_id,
        -- Strict sanitization block to parse binary indicator safely
        CAST(
            REGEXP_REPLACE(
                (REGEXP_MATCH(
                    (ai.openai_chat_complete(
                        'llama-3.1-8b-instant',
                        jsonb_build_array(
                            jsonb_build_object(
                                'role', 'user', 
                                'content', 'Analyze the dish name: ''' || dish_name || '''. Is this dish a hamburger, cheeseburger, or similar beef/veggie burger? Reply with exactly ''1'' for yes and ''0'' for no. Do not include any other text or punctuation.'
                            )
                        )
                    )->'choices'->0->'message'->>'content')::text,
                    '[0-9.]+'
                ))[1], 
                '[^0-9.]', 
                '', 
                'g'
            ) AS DOUBLE PRECISION
        ) AS is_burger
    FROM 
        dish
),
tourist_trap_paris_restaurants AS (
    SELECT 
        restaurant_id,
        restaurant_description
    FROM 
        location
    WHERE 
        LOWER(city) = 'paris'
        -- Vector distance threshold to isolate tourist-trap descriptors (typically < 0.4 distance)
        AND (ai.ollama_embed(
            'mxbai-embed-large',
            'tourist trap restaurant',
            host => 'http://pgai-ollama:11434'
        )::vector <=> restaurant_description_embedded) < 0.4
)
SELECT 
    ROUND(AVG(o.unit_price)::numeric, 2) AS average_hamburger_price,
    COUNT(DISTINCT o.dish_id) AS total_burger_dishes_evaluated,
    COUNT(DISTINCT ttpr.restaurant_id) AS tourist_trap_restaurants_found
FROM 
    order_Line o
JOIN 
    burger_classification bc ON o.dish_id = bc.dish_id
JOIN 
    tourist_trap_paris_restaurants ttpr ON o.restaurant_id = ttpr.restaurant_id
WHERE 
    NULLIF(bc.is_burger, NULL) = 1;
```

========================================================================================================= 


**Query:Where can I get great food with a busy, energetic vibe without needing a reservation 3 months in advance?**


``` 
SELECT 
    restaurant_id,
    restaurant_description,
    city,
    -- Measure the semantic distance to a lively, walk-in friendly dining atmosphere
    (ai.ollama_embed(
        'mxbai-embed-large',
        'lively energetic restaurant no reservation walk in',
        host => 'http://pgai-ollama:11434'
    )::vector <=> restaurant_description_embedded) AS vibe_similarity_distance
FROM 
    location
WHERE 
    --  filter to pull highly energetic, accessible concepts 
    (ai.ollama_embed(
        'mxbai-embed-large',
        'lively energetic restaurant no reservation walk in',
        host => 'http://pgai-ollama:11434'
    )::vector <=> restaurant_description_embedded) < 0.4
ORDER BY 
    vibe_similarity_distance ASC;
```

========================================================================================================= 

**Which restaurant has the absolute worst service?**


``` 
WITH review_scores AS (
    SELECT 
        ol.restaurant_id,
        -- Virtual Level: service_score (1.0 = Worst Service, 5.0 = Excellent Service)
        CAST(
            NULLIF(
                REGEXP_REPLACE(
                    (REGEXP_MATCH(
                        (ai.openai_chat_complete(
                            'llama-3.1-8b-instant',
                            jsonb_build_array(
                                jsonb_build_object(
                                    'role', 'user', 
                                    'content', 'Based on the customer review, rate the quality of the restaurant''s service on a scale from 1 to 5 (where 1 is extremely bad/worst service, 5 is excellent service, and 3 is neutral). If the review does not mention service, reply with 3. Reply ONLY with the number. Review: ' || ol.review
                                )
                            )
                        )->'choices'->0->'message'->>'content')::text, 
                        '[0-9.]+'
                    ))[1], 
                    '[^0-9.]', 
                    '', 
                    'g'
                ), 
                ''
            ) AS DOUBLE PRECISION
        ) AS service_score
    FROM 
        order_Line ol
    WHERE 
        ol.review IS NOT NULL 
        AND ol.review <> ''
)
SELECT 
    l.restaurant_id,
    l.city,
    l.country,
    AVG(rs.service_score) AS average_service_rating
FROM 
    review_scores rs
JOIN 
    location l ON rs.restaurant_id = l.restaurant_id
GROUP BY 
    l.restaurant_id, 
    l.city, 
    l.country
ORDER BY 
    average_service_rating ASC
LIMIT 1;
```

========================================================================================================= 


**Query:Give me a summary of the reviews for cheap restaurants with included service fees that are actually good**


``` 
WITH review_classification AS (
    SELECT 
        order_id,
        review,
        review_embedded,
        -- Virtual Level: service_fee_included (Value 1.0 = Yes, Value 0.0 = No)
        CAST(
            NULLIF(
                REGEXP_REPLACE(
                    (REGEXP_MATCH(
                        (ai.openai_chat_complete(
                            'llama-3.1-8b-instant',
                            jsonb_build_array(
                                jsonb_build_object(
                                    'role', 'user', 
                                    'content', 'Does the review indicate that service fees are included? Reply with 1 for yes, 0 for no. Review: ' || review
                                )
                            )
                        )->'choices'->0->'message'->>'content')::text, 
                        '[0-9.]+'
                    ))[1], 
                    '[^0-9.]', 
                    '', 
                    'g'
                ), 
                ''
            ) AS DOUBLE PRECISION
        ) AS service_fee_included
    FROM 
        order_Line
)
SELECT 
    -- AI-based Summarization aggregation of the filtered reviews
    (ai.openai_chat_complete(
        'llama-3.1-8b-instant',
        jsonb_build_array(
            jsonb_build_object(
                'role', 'user', 
                'content', 'give me one line summary: ' || STRING_AGG(review, ' ')
            )
        )
    )->'choices'->0->'message'->>'content')::text AS review_summary
FROM 
    review_classification
WHERE 
    -- 1. Filter: "With included service fees" (derived virtual level = 1)
    service_fee_included = 1.0
    
    -- 2. Filter: "Cheap" restaurants (semantic match using Text Embedding Similarity)
    AND ai.ollama_embed(
        'mxbai-embed-large', 
        'cheap', 
        host => 'http://pgai-ollama:11434'
    )::vector <=> review_embedded < 0.4
    
    -- 3. Filter: "Actually good" restaurants (semantic match using Text Embedding Similarity)
    AND ai.ollama_embed(
        'mxbai-embed-large', 
        'good', 
        host => 'http://pgai-ollama:11434'
    )::vector <=> review_embedded < 0.4;
```
========================================================================================================= 

**Query:Find not-so-expensive dishes **


``` 
WITH dish_prices AS (
    SELECT 
        d.dish_id,
        d.dish_name,
        ROUND(AVG(ol.unit_price)::numeric, 2) AS average_price
    FROM 
        dish d
    JOIN 
        order_Line ol ON d.dish_id = ol.dish_id
    GROUP BY 
        d.dish_id, 
        d.dish_name
),
dish_classification AS (
    SELECT 
        dish_id,
        dish_name,
        average_price,
        -- Virtual Level: is_affordable (Value 1.0 = Yes, Value 0.0 = No)
        CAST(
            NULLIF(
                REGEXP_REPLACE(
                    (REGEXP_MATCH(
                        (ai.openai_chat_complete(
                            'llama-3.1-8b-instant',
                            jsonb_build_array(
                                jsonb_build_object(
                                    'role', 'user', 
                                    'content', 'Is a dish named ''' || dish_name || ''' with an average price of $' || average_price || ' considered not-so-expensive/affordable? Reply with 1 for yes and 0 for no.'
                                )
                            )
                        )->'choices'->0->'message'->>'content')::text, 
                        '[0-9.]+'
                    ))[1], 
                    '[^0-9.]', 
                    '', 
                    'g'
                ), 
                ''
            ) AS DOUBLE PRECISION
        ) AS is_affordable
    FROM 
        dish_prices
)
SELECT 
    dish_id,
    dish_name,
    average_price
FROM 
    dish_classification
WHERE 
    is_affordable = 1.0;
```


========================================================================================================= 

# PREFERENCE QUERIES

========================================================================================================= 

**Query:Find a restaurant that first of all is cheap, and possibly has a terrace **


``` 
SELECT DISTINCT ON (l.restaurant_id)
    l.restaurant_id,
    l.city,
    l.country,
    l.restaurant_description,
    -- Preference Score: Lower distance means a higher likelihood of having a terrace
    (ai.ollama_embed(
        'nomic-embed-text',
        'terrace',
        host => 'http://pgai-ollama:11434'
    )::vector <=> l.restaurant_picture_embedded) AS terrace_distance
FROM 
    location l
JOIN 
    order_Line ol ON l.restaurant_id = ol.restaurant_id
WHERE 
    -- 1. Hard Filter: Must be "cheap" according to review embeddings
    ai.ollama_embed(
        'mxbai-embed-large',
        'cheap',
        host => 'http://pgai-ollama:11434'
    )::vector <=> ol.review_embedded < 0.4
ORDER BY 
    l.restaurant_id,
    -- 2. Preference Ranking: Put restaurants that match "terrace" first
    terrace_distance ASC;
```
========================================================================================================= 

**Query:Find the dishes that offer the best compromise between being cheap and having good reviews **


``` 
WITH dish_metrics AS (
    SELECT 
        d.dish_id,
        d.dish_name,
        -- Metric 1: Average unit price (lower is cheaper)
        AVG(ol.unit_price) AS average_price,
        
        -- Metric 2: Average distance to 'good' sentiment (lower is more positive)
        AVG(
            ol.review_embedded <=> ai.ollama_embed(
                'mxbai-embed-large', 
                'good', 
                host => 'http://pgai-ollama:11434'
            )::vector
        ) AS average_good_distance
    FROM 
        dish d
    JOIN 
        order_Line ol ON d.dish_id = ol.dish_id
    WHERE 
        ol.review_embedded IS NOT NULL
    GROUP BY 
        d.dish_id, 
        d.dish_name
)
SELECT 
    dish_id,
    dish_name,
    average_price,
    average_good_distance,
    -- Best compromise formula (lower score indicates optimal balance of price and rating)
    (average_price * average_good_distance) AS compromise_score
FROM 
    dish_metrics
ORDER BY 
    compromise_score ASC;
```




========================================================================================================= 
