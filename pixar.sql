/*
-- Inspect the Tables
SELECT * FROM box_office LIMIT 5;
SELECT * FROM pixar_films LIMIT 5;
SELECT * FROM genres LIMIT 5;
SELECT * FROM public_response LIMIT 5;
SELECT * FROM academy LIMIT 5;
SELECT * FROM pixar_people LIMIT 5;
*/

-- -------------------------------------------------------------
-- Films Overview
CREATE VIEW films_overview AS
SELECT 
    pf.film,
    YEAR(pf.release_date) AS release_year,
    pf.release_date,
    pf.run_time,
    pf.film_rating,
    bo.budget,
    bo.box_office_us_canada,
    bo.box_office_other,
    bo.box_office_worldwide,
    (bo.box_office_worldwide - bo.budget) AS profit,
    CASE 
        WHEN bo.budget IS NOT NULL AND bo.budget > 0 THEN (bo.box_office_worldwide - bo.budget) / bo.budget * 100 
        ELSE NULL 
    END AS roi,
    pr.rotten_tomatoes_score,
    pr.metacritic_score,
    pr.cinema_score,
    pr.imdb_score,
    COALESCE(n.num_nominations, 0) AS num_nominations,
    COALESCE(w.num_wins, 0) AS num_wins
FROM 
    pixar_films pf
LEFT JOIN 
    box_office bo ON pf.film = bo.film
LEFT JOIN 
    public_response pr ON pf.film = pr.film
LEFT JOIN 
    (SELECT film, COUNT(*) AS num_nominations FROM academy WHERE status = 'Nominated' GROUP BY film) n ON pf.film = n.film
LEFT JOIN 
    (SELECT film, COUNT(*) AS num_wins FROM academy WHERE status = 'Won' GROUP BY film) w ON pf.film = w.film;
    
-- -------------------------------------------
-- Genres Data
CREATE VIEW genres_data AS
SELECT 
    g.film,
    g.category,
    g.value
FROM 
    genres g;
    

-- -------------------------------------------
-- People Data
CREATE VIEW people_data AS
SELECT 
    pp.film,
    pp.role_type,
    pp.name
FROM 
    pixar_people pp;

-- -------------------------------------------
-- Award Categories
CREATE VIEW award_categories AS
SELECT 
    award_type,
    SUM(CASE WHEN status = 'Nominated' THEN 1 ELSE 0 END) AS num_nominations,
    SUM(CASE WHEN status = 'Won' THEN 1 ELSE 0 END) AS num_wins
FROM 
    academy
GROUP BY 
    award_type;
    
    
 -- -------------------------------------------   
-- Genre Performance
CREATE VIEW genre_performance AS
SELECT 
    g.value AS genre,
    COUNT(*) AS num_films,
    AVG(bo.box_office_worldwide) AS avg_box_office,
    AVG(pr.rotten_tomatoes_score) AS avg_rt_score
FROM 
    genres g
JOIN 
    box_office bo ON g.film = bo.film
JOIN 
    public_response pr ON g.film = pr.film
WHERE 
    g.category = 'Genre'
GROUP BY 
    g.value;
    
    
 -- -------------------------------------------   
-- Director Performance    
    CREATE VIEW director_performance AS
SELECT 
    pp.name AS director,
    COUNT(*) AS num_films,
    AVG(bo.box_office_worldwide) AS avg_box_office,
    AVG(pr.rotten_tomatoes_score) AS avg_rt_score
FROM 
    pixar_people pp
JOIN 
    box_office bo ON pp.film = bo.film
JOIN 
    public_response pr ON pp.film = pr.film
WHERE 
    pp.role_type = 'Director'
GROUP BY 
    pp.name;

    




