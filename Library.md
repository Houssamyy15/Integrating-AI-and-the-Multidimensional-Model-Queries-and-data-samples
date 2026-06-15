**This file contains a set of functions configured in PostgreSQL that the LLM can use to implement the queries.**


```
1.	Summarization-text
Name: Summarization-text
Description:  This is a function that summarizes text, in a concise way
Parameters: “input_R_column”, and “input_function_prompt” are parameters identified in the natural language query. Default value of the “input_function_prompt” parameter is “give me one line summary”
Code:
(ai.openai_chat_complete(
  			 “llama-3.1-8b-instant”,
   			  jsonb_build_array(
			  jsonb_build_object('role', 'user', 'content', 'input_function_prompt' STRING_AGG(input_R_column)))
  			  )->'choices'->0->'message'->>'content' )::text
```



  
```
2.	Text Embedding Similarity
Name: Text Embedding Similarity
Description: This is a function that embeds a text and calculates the similarity between the resulted vector embedding against an existing embedded column
Parameters  “input_R_column” and ” input_function_prompt” are parameters identified in the natural language query
Code: 
ai.ollama_embed(
			“mxbai-embed-large”,
			‘input_function_prompt’,
			host => ‘http://pgai-ollama:11434’)::vector
	<=> input_R_column<0.4
```




``` 
3.	Image Embedding Similarity
Name: Image Embedding Similarity
Description: This is a function that embeds a text and calculates the similarity between the resulted vector embedding against an existing embedded column of an image
Parameters:“input_R_column” and ” input_function_prompt” are parameters identified in the natural language query
Code: 
 ai.ollama_embed(
 				'nomic-embed-text',
				input_function_prompt,
				host => 'http://pgai-ollama:11434' )::vector
	 <=> input_R_column < 0.4
```



``` 
4.	Embedding Similarity
Name: Embedding Similarity
Description: This is a function that calculates the similarity between two existing vectors
Parameters: “input_R_column1/2” is a parameter identified in the natural language query
Code: 
input_R_column1<=> input_R_column2 < 0.4
```
