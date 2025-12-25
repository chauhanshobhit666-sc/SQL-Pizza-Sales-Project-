Select * From order_details;
Select * From orders;
Select * From pizza_types;
Select * From pizzas;



#Question 1 -  Query The Total Number Of Orders Placed?
Select count(distinct(order_id)) as Number_of_Orders From order_details;


#Question 2 - Query The Total Number Of Pizza Id Types? 
Select count(distinct(pizza_id)) as Number_Of_PizzaId From pizzas;


#Question 3 - Query The Total Number Of Pizza Types?
Select count(distinct(pizza_type_id)) as Number_of_PizzaTypes From pizza_types;


#Question 4 -  Query Total Order Quantity Placed?
Select count(quantity) as Total_Quantity From order_details;


#Question 5 - Query The First Date Of Transction And Last Date Of Transaction?
Select max(date) as Last_Date, min(date) as First_Date From orders; 


#Question 6 - Query The Total Revenue Generated ?
Select Sum(a.quantity * b.price) as Total_Revenue From order_details a
Left Join pizzas b On a.pizza_id = b.pizza_id;


#Question 7 - Query The Highest Priced Pizza? #Display Pizza Name, Price
With CTE as (Select b.name, a.price From pizzas a
Join pizza_types b On a.pizza_type_id = b.pizza_type_id),
CTE2 as (Select *, Dense_Rank () Over(Order By a.price Desc) as RNK From CTE)
		Select * From CTE2 
		Where RNK = 1;
	

#Question 8 - Query The Lowest Priced Pizza? #Display Pizza Name, Price
With CTE as (Select b.name, a.price From pizzas a
Join pizza_types b On a.pizza_type_id = b.pizza_type_id),
CTE2 as (Select *, Dense_Rank () Over(Order By a.price Asc) as RNK From CTE)
		Select * From CTE2 
		Where RNK = 1;
        
        
#Question 9 - Query The Pizza Ordered Qty By Size?
Select distinct b.size, count(a.pizza_id) as Number_Of_Pizzas From order_details a
Join pizzas b On a.pizza_id = b.pizza_id 
Group By b.size;


#Question 10 - Query The Pizza Ordered Qty By Category?
Select X.Category, count(c.pizza_id) as Number_Of_Pizzas 
From (Select distinct b.category as Category, a.pizza_id From pizzas a
Join pizza_types b On a.pizza_type_id = b.pizza_type_id) X
Join order_details c On X.pizza_id = c.pizza_id
Group By Category;


#Question 11 - Query The Pizza Ordered Qty By Pizza Name?
Select X.Name, count(c.pizza_id) as Number_Of_Pizzas 
From (Select distinct b.name as Name, a.pizza_id From pizzas a
Join pizza_types b On a.pizza_type_id = b.pizza_type_id) X
Join order_details c On X.pizza_id = c.pizza_id
Group By Name;


#Question 12 - Query The Top 7 Pizza Types Based on Orders Qty? Display Pizza Name, Order Qty
Select X.Name, count(c.pizza_id) as Number_Of_Pizzas 
From (Select distinct b.name as Name, a.pizza_id From pizzas a
Join pizza_types b On a.pizza_type_id = b.pizza_type_id) X
Join order_details c On X.pizza_id = c.pizza_id
Group By Name
Order By Number_Of_Pizzas Desc
Limit 7;   


#Question 13 - Query The Distribution Of Orders By Hour Of Day?
Select distinct(Hour(b.time)) as Hours, 
count(distinct (a.order_id)) as Number_Of_Orders From order_details a 
Join orders b On a.order_id = b.order_id 
Group By Hours;


#Question 14 - Query The Pizza Order Qty By Date And Calculate The Average Numbers Of Pizzas Ordered Per Day?
With CTE as (Select distinct(Date(b.date)) as Date, 
count(a.order_id) as Number_Of_Orders From order_details a 
Join orders b On a.order_id = b.order_id 
Group By Date)
Select Avg(Number_Of_Orders) as Average_Orders_Per_Day From CTE;


#Question 15 - Query The Top 7 Pizza Names By Revenue? #Display Pizza Name, Revenue , Orderqty
Select * From (Select *, Dense_Rank () Over (Order By Revenue Desc) as RNK 
From (Select c.name, X.Revenue, X.Qty 
From (Select Sum(a.quantity) as Qty, b.pizza_type_id, Sum(a.quantity * b.price) as Revenue 
From order_details a
Join pizzas b On a.pizza_id = b.pizza_id
Group By b.pizza_type_id) X
Join pizza_types c On X.pizza_type_id = c.pizza_type_id) Y) Z
Where RNK <= 7;


#Question 16 - Query The Percentage Contribution Of Each Pizza Category To Total Revenue?
Select c.category, Round(Sum(a.quantity * b.price) * 100 / (Select Sum(a.quantity * b.price) as Total_Revenue From order_details a
Left Join pizzas b On a.pizza_id = b.pizza_id), 2) as Percentage
From order_details a 
Left Join pizzas b On a.pizza_id = b.pizza_id 
Left Join pizza_types c On b.pizza_type_id = c.pizza_type_id
Group By c.category;


#Question 17 - Analyse the cumulative revenue generated over time?
With CTE as (Select distinct(b.date) as Days, Round(Sum(X.Total_Revenue), 2) as Revenue 
From (Select a.order_id, sum(a.quantity * c.price) as Total_Revenue 
From order_details a
Left Join pizzas c On a.pizza_id = c.pizza_id
Group By a.order_id) X
Left Join orders b On X.order_id = b.order_id
Group By Days)

Select *, Round(Sum(Revenue) Over(Order By Days), 2) as Cumulative_Revenue From CTE;


#Question 18 - Determine The Top 3 Most Ordered Pizza Types Based On Revenue For Each Category?
With CTE as (Select c.category, c.name, Sum(X.Total_Revenue) as Revenue 
From (Select c.pizza_type_id, sum(a.quantity * c.price) as Total_Revenue 
From order_details a
Left Join pizzas c On a.pizza_id = c.pizza_id
Group By c.pizza_type_id) X
Left Join pizza_types c On X.pizza_type_id = c.pizza_type_id
Group By c.category, c.name),

CTE2 as (Select *, Dense_Rank () Over (Partition By CTE.category Order By Revenue Desc) as RNK From CTE)
Select * From CTE2 
Where RNK <= 3;
