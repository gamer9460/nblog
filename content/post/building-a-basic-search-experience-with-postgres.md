---
title: "Building a basic search experience with Postgres"
date: 2023-01-30T20:32:20+05:30
draft: false
image: "img/postgres-search-experience-cover.png"
tags: ["postgres", "sql"]
categories: ["Engineering"]
author: "Bhupesh Varshney"
authorDes: "Software Developer at  Nurdsoft | Tech Writer |  Python & Golang"
authorImage: "img/bhupesh-varshney.jpg"
---

Building search functionality in products is a common task. Many solutions exist to solve this problem already. OpenSource tools like [`opensearch`](https://opensearch.org/) and [`meilisearch`](https://www.meilisearch.com/) are some examples that are very commonly used. Using a 3rd party tool to build a "full-text search" is a good bet if you have a lot of data (i.e. a lot of users).

The goal of this post is to have a look at some in-built tools to build a minimalist search feature when your data is backed by a Postgres (or any SQL) database. Here is a rundown of what we will be covering

- [`ILIKE` operator](#ilike-operator)
- [`SIMILAR TO` operator](#similar-to-operator)
- [POSIX Regular Expressions](#posix-regular-expressions)
- [Fuzzy Searching](#fuzzy-searching)
  - [Trigram `pg_trgm`](#trigram-pg_trgm)
  - [Levenshtein Matching](#levenshtein-matching)
- [Getting to indexes](#getting-to-indexes)
- [Full-Text Search using `tsvector` and `tsquery`](#full-text-search-using-tsvector-and-tsquery)
- [Summary](#summary)
- [Resources](#resources)

## `ILIKE` operator

The most basic and simplest approach to implement simple “pattern matching”. The ILIKE operator takes a pattern and returns results while ignoring the case of results.

```sql
SELECT * FROM my_table WHERE my_column ILIKE'% my pattern %';
```

The wildcard `%` is used to match any number of characters. Similar to ILIKE is the [`LIKE`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-LIKE) operator which returns results in case-sensitive mode.

This is easy to implement, but queries can easily become long when multiple columns are used which can be a hassle to maintain if you have to replicate a similar approach among multiple tables.

```sql
SELECT *
FROM my_table
WHERE my_column ILIKE '% my pattern %'
    OR my_column2 ILIKE '% my pattern %'
    OR my_column3 ILIKE '% my pattern %'
    OR my_column4 ILIKE '% my pattern %'
    OR my_column5 ILIKE '% my pattern %'
    ...
```

On top of that, custom enum types and dates need to be typecast, because [`ILIKE`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-LIKE) only works on TEXT data type.

```sql
SELECT *
FROM my_table
WHERE
    to_char(created_at, 'mm/dd/yy') ILIKE '% my pattern %'
    OR custom_enum_type_column::text ILIKE '% my pattern %';
```

## `SIMILAR TO` operator

This operator lets us use [`regular expressions`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-SIMILARTO-REGEXP) in SQL queries and returns true/false if a match is found.

```sql
SELECT *
FROM my_table
WHERE my_column SIMILAR TO 'string%'='t';
```

Not very commonly used and is generally avoided, since introducing regex patterns in SQL queries is not an ideal solution.

## POSIX Regular Expressions

POSIX regular expressions are a better way to match patterns than the [`ILIKE`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-LIKE) and [`SIMILAR TO`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-SIMILARTO-REGEXP) operators. The most common example of regex usage is the [`grep`](https://www.postgresql.org/docs/15/app-postgres.html) tool.

The operator `~` can be used to for POSIX regex matches. Where `*` is used of case-insensitive matches & `!` represents the logical NOT operation.

```bash
'pacenthink' ~ 'p.c'           = true
'pacenthink' ~* 'thi'          = true
'pacenthink' !~ 'pacenthink'   = false
'pacenthink' !~* 'PACEANTHINK' = true
```

## Fuzzy Searching

### Trigram `pg_trgm`

A trigram is a group of three consecutive characters taken from a string.

We can measure the similarity of two strings by counting the number of trigrams they share.

> To use the [`pg_trgm`](https://www.postgresql.org/docs/current/pgtrgm.html) extension you will have to first enable it using [`CREATE EXTENSION pg_trgm;`](https://www.postgresql.org/docs/current/pgtrgm.html)

Let's take a quick overview of some common trigram functions in Postgres.

1. `show_trgm`

   Returns array of all the trigrams in the given string (no actual use, good for debugging).

   ```sql
   SELECT show_trgm('pacenthink');

   -- output

   ["  p"," pa","ace","cen","ent","hin","ink","nk ","nth","pac","thi"]
   ```

2. `similarity`

   Similarity ranges from 0 (not similar) to 1 (exact match).

   ```sql
   SELECT similarity('pacenthink', 'think')

   -- output
   0.30769232
   ```

Once you have the extension enabled, you can do similar word searches

```sql
SELECT * FROM my_table
WHERE SIMILARITY(my_column, 'word') > 0.3
```

### Levenshtein Matching

The Levenshtein distance is the distance between two words, i.e., the minimum number of single-character edits required for both strings to match.

> To use this functionality, we need to enable another extension called [`fuzzystrmatch`](https://www.postgresql.org/docs/15/fuzzystrmatch.html) using [`CREATE EXTENSION fuzzystrmatch;`](https://www.postgresql.org/docs/15/fuzzystrmatch.html)

```sql
SELECT * FROM my_table WHERE levenshtein(my_column, 'MyStr') < 3
```

The above query will match all `my_column` values which have a Levenshtein distance of less than 3 from the string `MyStr`.

## Getting to indexes

To index [`LIKE`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-LIKE) & [`SIMILAR TO`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-SIMILARTO-REGEXP) the [`pg_trgm`](https://www.postgresql.org/docs/current/pgtrgm.html) module supports two PostgreSQL index types: **GIST** and **GIN**.

- A [`GiST`](https://www.postgresql.org/docs/15/gist.html) (Generalized Search Tree) index is lossy, meaning that the index may produce false matches, and it is necessary to check the actual table row to eliminate such false matches. (PostgreSQL does this automatically). Use GIST index when you are storing data like longitudes, latitudes, ip address etc.

  ```sql
  CREATE INDEX index_name ON my_table USING GIST (my_column);
  ```

- [`GIN`](https://www.postgresql.org/docs/15/gin.html) indexes are not lossy, but their performance depends logarithmically on the number of unique words.

  ```sql
  CREATE INDEX index_name ON my_table USING GIN (my_column gin_trgm_ops);

  -- for multiple columns
  CREATE INDEX index_name ON my_table USING GIN (my_column1, my_column2 gin_trgm_ops);
  ```

  When using GIN indexes with [`pg_trgm`](https://www.postgresql.org/docs/current/pgtrgm.html), Postgres will split the row values into trigrams.

> As a rule of thumb, a GIN index is faster to search than a GiST index, but slower to build or update; so GIN is better suited for static data and GiST for often-updated data.

## Full-Text Search using `tsvector` and `tsquery`

First, let's look at the definition (source Wikipedia):

> In text retrieval, full-text search refers to techniques for searching a single computer-stored document or a collection in a full-text database. The full-text search is distinguished from searches based on metadata or on parts of the original texts represented in databases.

This introduces a new term, "document" which is the unit of searching in a full-text search system; for example, an article or email message. Note that a "document" is not related to a table but rather to data, meaning we can have a document encompassing multiple columns and tables.

Full-text search in postgres allows for an efficient search for phrases and words within large amounts of text data.
Different functions available to Postgres can be used to achieve full-text search:

1. **to_tsvector** for creating a list of tokens (the tsvector data type, where ts stands for "text search");
2. **to_tsquery** for querying the vector for occurrences of certain words or phrases.

```sql
SELECT to_tsvector('The quick brown fox jumped over the lazy dog.');

-- output
'brown':3 'dogs':9 'fox':4 'jumped':5 'lazy':8 'over':6 'quick':2 'the':1,7
```

Full text searching in PostgreSQL is based on the match operator `@@`, which returns true if a tsvector (document) matches a tsquery (query). It doesn't matter which operator type is written first:

```sql
SELECT to_tsvector('The quick brown fox jumped over the lazy dog') @@ to_tsquery('brown & fox');

-- output
TRUE
```

A [`tsquery`](https://www.postgresql.org/docs/current/datatype-textsearch.html#DATATYPE-TSQUERY) contains search terms, which must be already-normalized lexemes, and may combine multiple terms using AND, OR, NOT, and FOLLOWED BY operators.

```sql
SELECT to_tsquery('fat & rat');

-- output

'fat' & 'rat'
```

The following shows the difference between casting and using the function [`to_tsquery()`](https://www.postgresql.org/docs/current/datatype-textsearch.html#DATATYPE-TSQUERY)

```sql
SELECT 'impossible'::tsquery, to_tsquery('impossible');

-- output
   tsquery    | to_tsquery
--------------+------------
 'impossible' | 'imposs'
```

## Summary

The best way to implement a basic (or even full-text search) for rows in order of thousands is to have a GIN index on columns required used either via [`tsvector`](https://www.postgresql.org/docs/current/datatype-textsearch.html#DATATYPE-TSVECTOR) approach or using the [`ILIKE`](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-LIKE) operator.

Note that having any kind of index will slow down INSERTS, UPDATES, and DELETEs. For tables with an extremely high volume of transactions, we have to be very careful about adding indexes. For most tables in most systems, this is not an issue. In those cases opting for a solution like elastic search is a good bet.

## Resources

- [Pattern Matching](https://www.postgresql.org/docs/current/functions-matching.html)
- [Preferred Index Types for Text Search](https://www.postgresql.org/docs/15/textsearch-indexes.html)
- [Understanding Postgres GIN Indexes: The Good and the Bad](https://pganalyze.com/blog/gin-index)
