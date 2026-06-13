Query code and execution:

**NLQ1:**
```SELECT 
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
```SELECT 
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
```SELECT 
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

``` WITH Restaurant_Continent_Lookup AS (
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

``` SELECT 
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

``` SELECT 
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
```SELECT 
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

```   SELECT 
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

```   WITH Restaurant_Continent_Lookup AS (
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


```WITH OrderContext AS (
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

``` SELECT 
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
