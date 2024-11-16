##1.How many times does the average user post?
SELECT round((SELECT COUNT(ID)FROM photos)/(SELECT COUNT(ID) FROM users),2) as count_avg_posts;

##2.Find the top 5 most used hashtags
select tagname.tag_id,tag_name as most_used_hashtags,tagname.hash_counts 
from tags
inner join
(
select tag_id,count(*) as hash_counts from photo_tags
group by tag_id
)
tagname on tags.id=tagname.tag_id
order by tagname.hash_counts desc
limit 5;

##3.Find users who have liked every single photo on the site.
select username,likecount.user_id,likecount.count from users
inner join
(select user_id,count(*) as count from likes
group by user_id)likecount on users.id=likecount.user_id

having likecount.count=(select count(ID) from photos)
order by likecount.user_id ;


##4.  Retrieve a list of users along with their usernames and the rank of their account creation,
##    ordered by the creation date in ascending order.

With user_info as
(
select *,
rank() over (order by created_at) as Ranking from users
order by created_at asc
)
select * from user_info;

##5.  List the comments made on photos with their comment texts, photo URLs, 
##    and usernames of users who posted the comments. Include the comment count for each photo.
select comment_text,comments.user_id,username,comments.photo_id,photos.image_url,
commentcount.cc from comments
inner join users on comments.user_id=users.id
inner join photos on comments.photo_id=photos.id
inner join
(select photo_id,count(*) as cc from comments
group by photo_id)commentcount on photos.id=commentcount.photo_id; 

##6.For each tag, show the tag name and the number of photos associated with that tag. 
##  Rank the tags by the number of photos in descending order.

select id,tag_name,pt.tag_photo_count,rank() over (order by pt.tag_photo_count desc) as ranking from tags
inner join 
(select tag_id,count(*) as tag_photo_count from photo_tags
group by tag_id)pt on tags.id=pt.tag_id;

##7. List the usernames of users who have posted photos along with the count of photos they have posted. 
##   Rank them by the number of photos in descending order.

select user_id,username.username,count(*) as count_of_photos,rank() over (order by count(*) desc) as ranking from photos
join
(select id,username from users)username on photos.user_id=username.id
group by user_id;

##8.Display the username of each user along with the creation date of their first posted photo
##  and the creation date of their next posted photo.
select user_name.id,user_name.username,image_url,
lag(photos.created_at) over (partition by photos.user_id order by photos.created_at) as first_creation_date,
lead(photos.created_at) over (partition by photos.user_id order by photos.created_at) as next_creation_date 
from photos
join
(select id,username from users)
user_name on photos.user_id=user_name.id;

##9. For each comment, show the comment text, the username of the commenter, 
##   and the comment text of the previous comment made on the same photo.
select user_id,user_name.username,photo_id,comments.comment_text,
lag(comment_text) over (partition by photo_id order by comments.created_at) as prev_comment
from comments
inner join 
(select id,username from users)user_name
 on comments.user_id=user_name.id;
 
 ##10.Show the username of each user along with the number of photos they have posted
 ##and the number of photos posted by the user before them and after them, based on the creation date.
 select user_id,users.username,count(*) as no_of_photos,
sum(count(*)) over(order by photos.created_at rows between UNBOUNDED PRECEDING AND 1 PRECEDING)as preceeding_sum,
sum(count(*)) over(order by photos.created_at rows between 1 FOLLOWING AND UNBOUNDED FOLLOWING )as succeeding_sum
from photos
inner join users on photos.user_id=users.id
group by user_id,photos.created_at;
 











