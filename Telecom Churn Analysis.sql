-- 1. Count the total number of customers.

	Select count(customerid) 
    from customer_churn;
    -- 7032 customers present in the data
    
-- 2. Get the total number of churned vs non-churned customers.

	Select count(customerid) as Customer_Count, Churn
    from customer_churn
    group by churn;
	-- 5163 Customers are not churned and 1869 are churned
    
-- 3. List all unique values in the InternetService column

	Select distinct InternetService 
    from customer_churn;
    -- 3 Unique Internetservice providers are there

-- 4. Get the average MonthlyCharges per gender.

	Select Round(avg(MonthlyCharges),2) as Avg_Monthly_Charges,  gender
    from customer_churn
    group by gender
    order by Avg_Monthly_Charges desc;
    --  65.22 is the average montlhy charges for female and 64.39 for male

-- 5. Count how many customers are senior citizens.

	Select count(seniorcitizen) as No_of_seniorcitizens
    from customer_churn
    where SeniorCitizen = 1;
    -- 1142 senior citizens are there 
    
-- 6. Find top 5 customers with the highest TotalCharges.

	With Top_Customers As (
		Select customerid, Round(TotalCharges),
		ROW_NUMBER() Over (Order by TotalCharges DESC) as Customer_Rank
		from customer_churn
    )
    Select * from Top_Customers 
    Where Customer_Rank <=5;
    
-- 7. Show the number of customers grouped by Contract type
	
    Select count(customerid) as Customer_Count, Contract
    from customer_churn
    group by Contract
    order by 1 desc;
    
-- 8. List all customers who pay more than ₹100 in MonthlyCharges

	Select distinct Customerid, MonthlyCharges
    from customer_churn
    where MonthlyCharges > 100
    order by 2 DESC;

-- 9. Get the number of customers who have both Phone and Internet Service

	Select count(customerid) as Customer_Count
    from customer_churn
    where PhoneService = 'Yes' and InternetService != 'No';
    -- 4832 Customers have opted for both phoneservice and Internet service
    
-- 10. Find customers who have churned and used Fiber optic internet

	Select customerid
    from customer_churn
    Where InternetService = 'Fiber Optic' and Churn = 'Yes';
    
-- 11. Create tenure buckets (0–12, 13–24, 25–48, 49+) and count customers in each

	Select count(customerid) as CustomerCount,
    Case
		When Tenure >= 0 and Tenure <= 12 Then '0-12'
        When Tenure >= 13 and Tenure <= 24 Then '13-24'
        When Tenure >= 25 and Tenure <= 48 Then '25-48'
        Else '49+'
	End AS Tenure_Buckets
    from customer_churn
    group by Tenure_Buckets;
    
-- 12. Get churn rate (%) by Contract type.

	SELECT Contract, 
    ROUND(AVG(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),2) * 100 AS churn_rate_percentage
	FROM customer_churn
	GROUP BY Contract;

-- 13. Find average MonthlyCharges for customers who churned vs those who didn't.

	Select Round(avg(MonthlyCharges),2) as Monthly_Avg_Charge,
    Churn
    from customer_churn
    Group by Churn
    order by 2 Desc;
    
-- 14. Rank PaymentMethods by number of churned customers

	Select PaymentMethod, count(churn) as Churn_Count,
    ROW_NUMBER() OVER (order by count(churn) desc) as Churn_Rank
    From customer_churn
    Where Churn = 'Yes'
    Group by PaymentMethod;
    
-- 15. Identify the top 3 InternetService types with the highest churn rate

	With High_Churn as (
    Select ROUND(AVG(Case When Churn = 'Yes' Then 1 Else 0 END),2)*100 as Churn_Rate,
    InternetService
    from customer_churn
    group by InternetService
    )
	Select *,ROW_NUMBER() Over(order by Churn_Rate desc) as Chur_Rank
    from High_Churn;
	
-- 16. What is the average tenure of customers grouped by PaymentMethod?

	Select Round(avg(tenure),2) as Avg_tenure,
    Paymentmethod
    from customer_churn
    group by PaymentMethod
    order by avg_tenure desc;
    
-- 17. Which Contract type has the lowest churn rate?

	With Churn_Extract as (
    Select contract, ROUND(Avg(CASE WHEN Churn = 'Yes' Then  1 Else 0 END)*100) AS Churn_Rate
    from customer_churn
    group by contract
    )
    Select *,ROW_NUMBER() Over (order by churn_rate asc) as Churn_Rank
    from Churn_Extract
    WHERE Churn_Rank = 1;

-- 18. Show customers who have churned and were on a Month-to-month contract for less than 12 months.

	Select CustomerID
    From customer_churn
    Where Churn = 'Yes' and  Contract = 'Month-to-month' and Tenure < 12;
    
-- 19. Which combination of InternetService and Contract has the highest average MonthlyCharges?

	Select ROUND(avg(MonthlyCharges),2) as Avg_Monthly_Charge, InternetService, Contract
    From Customer_Churn
    Group by 2,3
    order by 1 desc;
	-- Fiber optic and Two year combination has the highest monthly charges
    
-- 20. Count how many customers have no OnlineSecurity, OnlineBackup, and DeviceProtection

	Select count(customerid) as Customer_count
    from Customer_churn
    Where OnlineSecurity = 'No' and OnlineBackup = 'No' and DeviceProtection = 'No';
    
-- 21. For each Contract type, calculate the churn rate and also show the average tenure of churned customers.

	SELECT 
    ROUND(AVG(CASE WHEN CHURN = 'YES' THEN 1 ELSE 0 END), 2) AS Churn_rate, 
    ROUND(AVG(CASE WHEN CHURN = 'YES' THEN Tenure END), 2) AS Avg_Tenure_Rate,
    Contract
	FROM customer_churn
	GROUP BY Contract
	ORDER BY Churn_rate DESC;

-- 22. Find the top 3 most common service combinations among churned customers

	WITH Service_Combos AS (
    SELECT 
        CONCAT_WS('-', PhoneService, InternetService, OnlineSecurity, OnlineBackup, TechSupport) AS Service_Pack,
        CustomerID
    FROM customer_churn
    WHERE Churn = 'Yes'
)
	SELECT 
		Service_Pack, 
		COUNT(CustomerID) AS Combo_Count
	FROM Service_Combos
	GROUP BY Service_Pack
	ORDER BY Combo_Count DESC
	LIMIT 3;

-- 23. Calculate the cumulative number of churned customers month-over-month

	SELECT 
    Tenure AS Tenure_Month,
    COUNT(*) AS Churn_Count,
    SUM(COUNT(*)) OVER (ORDER BY Tenure) AS Cumulative_Churn_Count
	FROM customer_churn
	WHERE Churn = 'Yes'
	GROUP BY Tenure
	ORDER BY Tenure;

-- 24. Which PaymentMethod shows the strongest correlation between high MonthlyCharges and churn?

	SELECT 
    PaymentMethod, 
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges,
    COUNT(*) AS Churned_Count
	FROM customer_churn
	WHERE Churn = 'Yes'
	GROUP BY PaymentMethod
	ORDER BY Avg_Monthly_Charges DESC;

-- 25. Flag high-risk customers based on churn patterns (without knowing if they’ve churned)

	WITH Churn_Patterns AS (
		SELECT 
			CONCAT_WS('-', MultipleLines, InternetService, TechSupport, Contract) AS Service_Profile,
			COUNT(*) AS Churned_Count
		FROM customer_churn
		WHERE Churn = 'Yes'
		GROUP BY Service_Profile
		HAVING COUNT(*) > 10 
)

		SELECT 
			CustomerID,
			MonthlyCharges,
			Tenure,
			CONCAT_WS('-', MultipleLines, InternetService, TechSupport, Contract) AS Service_Profile,
			'Yes' AS AtRisk_Flag
		FROM customer_churn
		WHERE Churn = 'No'
		  AND CONCAT_WS('-', MultipleLines, InternetService, TechSupport, Contract) IN (
			  SELECT Service_Profile FROM Churn_Patterns
		  )
		  AND MonthlyCharges > 80  -- You can adjust this
		  AND Tenure < 6;

