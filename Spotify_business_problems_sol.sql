-- Advanced_sql_project
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA

select count(*) from spotify;

Select  count (distinct album) from spotify;

Select  count (distinct artist) from spotify;

Select distinct album_type from spotify;

select duration_min from spotify;

select max(duration_min) from spotify;

select min(duration_min) from spotify;

Select * from spotify
where duration_min = 0;

Delete from spotify
where duration_min = 0;

Select distinct channel from spotify;

Select distinct most_played_on from spotify;

-- ----------------------------
-- Data Analysis -Easy Category
-- -----------------------------


-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
Select 
       track,
	   stream 
from spotify
where stream > 1000000000;
-- 2.List all albums along with their respective artists.

Select
      Distinct album,
	  artist 
from Spotify
order by 1;

-- 3.Get the total number of comments for tracks where licensed = TRUE.

Select
      sum(comments) as Total_comments
from spotify
Where Licensed = 'True';

-- 4.Find all tracks that belong to the album type single.

Select 
      track
	  album_type 
from spotify
where album_type = 'single';

-- 5 Count the total number of tracks by each artist.

Select 
      artist,
	  Count(track) as total_tracks
 from spotify
 Group by 1;

-- -------------
 -- Medium Level
 -- ------------
-- 6.Calculate the average danceability of tracks in each album.

SELECT
       album,
	   avg(danceability) as avg_danceability
from spotify
group by 1;

-- 7.Find the top 5 tracks with the highest energy values.

Select 
      track,
	  energy
from spotify
order by energy desc
Limit 5;

-- 8.List all tracks along with their views and likes where official_video = TRUE.

SELECT 
      track,
	  views,
	  likes
from spotify
where official_video = 'TRUE';

-- 9.For each album, calculate the total views of all associated tracks.

SELECT 
      track,
	  album,
	  sum(views) as total_views
from spotify
group by 1,2
order by 3;

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT 
      track,
	  coalesce(sum(case when most_played_on = 'Youtube' then stream END),0) as streamed_on_youtube,
	  coalesce(sum(case when most_played_on = 'Spotify' then stream END),0) as streamed_on_spotify
 from spotify
Group by 1
)as t1
where 
      streamed_on_spotify > streamed_on_youtube
	  And
	  Streamed_on_youtube <> 0

-- ---------------------
-- Advanced Level
-- ----------------------
-- 11.Find the top 3 most-viewed tracks for each artist using window functions.
  
  with ranking_artist
	as
	(Select 
	      artist,
		  track,
		  sum(views) as total_view,
		  Dense_rank() over (partition by artist order by sum(views) desc) as rank
	from spotify
	 group by 1,2
	 order by 1,3 DESC
	 )
	 select * from ranking_artist
	 where rank <= 3;
	 
-- 12.Write a query to find tracks where the liveness score is above the average.

SELECT 
       track,
	   artist,
	   liveness
from spotify
where liveness > (select avg(liveness) from spotify);

-- 13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte
AS
(SELECT 
       album,
	   max(energy) as highest_energy,
	   min(energy) as lowest_energy
FROM SPOTIFY
group by 1
)
select 
      album,
	  highest_energy - lowest_energy as energy_diff
from cte
order by 2 desc;

-- 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT
    track,
    artist,
    energy,
    liveness,
    (energy / liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2;


-- 15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_likes
FROM spotify;

-- Query optimization

Explain Analyze
Select 
      artist,
	  track,
	  views
from spotify
where artist ='Gorillaz'
      and
	  most_played_on = 'Youtube'
order by stream desc
limit 25;

Create Index artist_index ON Spotify (artist);
