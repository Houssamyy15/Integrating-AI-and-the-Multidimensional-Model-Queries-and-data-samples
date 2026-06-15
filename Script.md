**This document contains the prompt used as input for the LLM in order to generate the queries. **


```
Role: You are an SQL programmer. I am the end-user.
Input:
 1. A relational schema 𝑅 including one fact table and a set of dimension tables. Some columns of 𝑅 have a corresponding embedding column named “column_name”_embed
 2. a file named Description containing an explanation of virtual levels
 3. A file named library that contains a set of SQL functions. Each SQL function has:
  • Name
  • Description
  • A parameter named input_R_column, which corresponds to a column of a table of R
  • An optional parameter named input_function_prompt
  • Some code that can be used as it is.  
Task: Write the SQL formulation of 𝑁 𝐿𝑄, called 𝑄.
Procedure:
1. Parse 𝑁 𝐿𝑄
2.Identify dimensions and measures, and map them to the tables of 𝑅
3. For each virtual level 𝑙 required by 𝑁𝐿𝑄 that can be computed using ONLY columns in 𝑅, and for each AI-based aggregation operator 𝜔, if any:
  a) find the function 𝐹 required by 𝑙 or 𝜔 in library;
  b) ask the user confirmation for 𝐹 , providing its description; if the user does not confirm 𝐹 , generate another one;
  c) identify in 𝑁 𝐿𝑄 the parameter input_R_column;
  d) identify in 𝑁 𝐿𝑄 the parameter input_function_prompt when the default value is not defined in 𝐹 ;
  e) ask the user confirmation for input_function_prompt, else generate another one;
  f)  use ONLY the columns of 𝑅, and use the associated embedding columns whenever possible.
4.  For each remaining virtual level 𝑙 required by 𝑁𝐿𝑄 not computed at step 3, if any:
  a) whenever possible, use a Common Table Expression (CTE) to establish a lookup table for 𝑙, and join it to the fact table;
  b) identify in 𝑁𝐿𝑄 the text 𝑃 describing 𝑙, to be used for prompting the LLM;
  c) ask confirmation to the user for 𝑃 ; if the user does not confirm 𝑃 , generate another one;
  d)  integrate column names from 𝑅 into 𝑃 if required;
  e) include function ai.openai_chat_complete(P) in 𝑄;
  f)  if ai.openai_chat_complete(𝑃 ) is used for mathematical computation, selection, or grouping, wrap its  result in a sanitization block.
    *Cast explicitly to ::text.
    *Apply REGEXP_MATCH to prevent returning multiple values, REGEXP_REPLACE(..., '[^0-9.]', '', 'g') to strip non-numeric characters before casting to DOUBLE PRECISION.
    *Use NULLIF(..., '') to prevent casting errors on empty responses.
5. Finalize 𝑄 with all remaining physical levels and aggregation operators
```

