select * from spotify s 


/*
 * Easy Level Question.
 
Q1. Retrieve the names of all tracks that have more than 1 billion streams.
Q2. List all albums along with their respective artists.
Q3. Get the total number of comments for tracks where licensed = TRUE.
Q4. Find all tracks that belong to the album type single.
Q5. Count the total number of tracks by each artist.

*/

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify 
where stream > 1000000000

-- Q2. List all albums along with their respective artists.

select 
	distinct album,
	artist 
from spotify 
group by 1,2


-- Q3. Get the total number of comments for tracks where licensed = TRUE.

select 
	
	sum(comments) as total_comments
from spotify 
where licensed = 'true'



-- Q4. Find all tracks that belong to the album type single.

select 
	 track,
	 album
from spotify 
where album_type = 'single'

-- Q5. Count the total number of tracks by each artist.

select 
	artist,
	
	count(track) as total_count
	
from spotify 
group by 1
order by 2










/*
 * All Are Medium Level Question.

Q6. Calculate the average danceability of tracks in each album.
Q7. Find the top 5 tracks with the highest energy values.
Q8. List all tracks along with their views and likes where official_video = TRUE.
Q9. For each album, calculate the total views of all associated tracks.
Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.
   
    * */

--Q6. Calculate the average danceability of tracks in each album.
select 
	album,
	avg(danceability)
from spotify 
group by 1
	
--Q7. Find the top 5 tracks with the highest energy values.

select 
	track,
	max(energy)
from spotify 
group by 1
order by 2 desc 
limit 5


--Q8. List all tracks along with their views and likes where official_video = TRUE.


select * from spotify


select
	track,
	sum(likes) as total_likes,
	sum(views) as total_views
from spotify 
where official_video = true
group by 1
order by 3 desc



--Q9. For each album, calculate the total views of all associated tracks.

select
	album,
	track,
	sum(views) as total_views
from spotify 
group by 1,2



--Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from
(
select 
	track,
	-- most_played_on,
	coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as stream_on_youtube,
	coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as stream_on_spotify
from spotify
group by 1
) as t1
where 
	stream_on_spotify > stream_on_youtube
	--and
	--stream_on_youtube <> 0


/*
 * These Are Advanced Question.
 
Q11. Find the top 3 most-viewed tracks for each artist using window functions.
Q12. Write a query to find tracks where the liveness score is above the average.
Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

*/
	
	

--Q11. Find the top 3 most-viewed tracks for each artist using window functions.
with ranking 
as
(select 
	artist,
	track,
	sum(views) as total_view,
	dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1, 2
order by 1, 3 desc
)
select * from ranking 
where "rank" <= 3

	
	
-- step 1. total track_views
with track_views as
(select 
	artist,
	track,
	sum(views) as total_views
from 
	spotify 
group by 
	artist , track
),
rank_tracks
as
(select
	artist,
	track,
	total_views,
	row_number() over (partition by artist order by total_views desc) as rnk
	from 
		track_views
	
)

select * from rank_tracks
where rnk <= 3

	
-- Get top 3 most-viewed tracks per artist using ROW_NUMBER
WITH track_views AS (
    SELECT
        artist,
        track,
        SUM(views) AS total_views
    FROM
        spotify
    GROUP BY
        artist, track
),
ranked_tracks AS (
    SELECT
        artist,
        track,
        total_views,
        ROW_NUMBER() OVER (PARTITION BY artist ORDER BY total_views DESC) AS row_num
    FROM
        track_views
)
SELECT
    artist,
    track,
    total_views
FROM
    ranked_tracks
WHERE
    row_num <= 3;

	
	
-- Q12. Write a query to find tracks where the liveness score is above the average.

select
	track,
	artist,
	liveness
from
	spotify
where liveness > (select avg(liveness) from spotify)



-- Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.


WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC















