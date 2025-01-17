/* Who is the senior most employee based on job title? */

SELECT * FROM employee
ORDER BY levels desc
LIMIT 1;



/* Which countries have the most invoices? */

SELECT billing_country, COUNT(*) as c
FROM invoice
GROUP BY billing_country
ORDER BY c desc;



/* What are top 3 values of total invoice */

SELECT total FROM invoice
ORDER BY total desc
LIMIT 3;



/* Which city has the best customer? We would like to throw a promotion music Festival in the city we made the most money.write
a query the returns one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals. */

SELECT SUM(total) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc;



/* Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that
returns the person who has spent the most money. */

SELECT  customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1;



/* Write a query to return the email, first name, last name & genre of all Rock Music Listeners. Return your list ordered
alphabetically by email starting with A. */

SELECT DISTINCT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
   SELECT track_id FROM track
   JOIN genre ON track.genre_id = genre.genre_id
   WHERE genre.name LIKE 'Rock'
)
ORDER BY email;



/* Let's invite all the artist who have written the most rock music in our dataset. Write a query that return the Artist name
and total track count of the top 10 rock bands */

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;



/* Return all the track names that have a song lenght longer than the average song length. Return the Name and Milliseconds for 
each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
      SELECT AVG(milliseconds) AS avg_track_length
	  FROM track
)
ORDER BY milliseconds DESC;



/* Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent. */

WITH best_selling_artist AS (
   SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
   SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
   FROM invoice_line
   JOIN track ON track.track_id = invoice_line.track_id
   JOIN album ON album.album_id = track.album_id
   JOIN artist ON artist.artist_id = album.artist_id
   GROUP BY artist.artist_id
   ORDER BY total_sales DESC
   LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the 
highest amount of puchase. Write a query that returns each country along with the top Genre. For countries Where the maximum number of 
purchases is shared return all Genres.*/

WITH popular_genre as (
    SELECT COUNT(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1;



/* Write a query that determines the customer that has spent the most on music for each country. write a query that returns the
country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount. */

WITH customer_with_country AS (
   SELECT customer.customer_id,first_name,last_name, billing_country, SUM(total) AS total_spent,
   ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS row_no
   FROM invoice
   JOIN customer on customer.customer_id = invoice.customer_id
   GROUP BY 1,2,3,4
   ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country
WHERE row_no <= 1;



