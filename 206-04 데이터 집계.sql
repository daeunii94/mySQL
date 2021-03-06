/*
	정원혁 2014.11. 
	이장래 저 "SQL Server 2012 운영과 개발 : 이장래와 함께하는" 의 스크립트를 migration
	http://www.yes24.com/SearchCorner/Search?scode=032&ozsrank=1&author_yn=y&query=%c0%cc%c0%e5%b7%a1&domain=all
	
	https://github.com/wonhyukc/mySQL
*/
use HRDB;
SELECT database();

-- 
--  6.4 데이터 집계
-- 



-- 
--  A. 기본적인 데이터 집계
-- 


-- 1) 집계 함수 사용

-- 근무 중인 직원들의 급여의 합 구하기
SELECT SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL;

--  근무 중인 직원들의 급여의 최대값, 최소값, 최대값 - 최소값을 구하는 쿼리를 작성하자.

SELECT MAX(Salary) AS 'Max_Salary', MIN(Salary) AS ' Min_Salary',
			 MAX(Salary) - MIN(Salary) AS ' Diff_Salary'
	FROM Employee
	WHERE RetireDate IS NULL;


-- 2) 집계 함수와 NULL 값 예제

UPDATE Employee
	SET Salary = NULL
	WHERE EmpID = 'S0020';

SELECT COUNT(*) AS 'EmpCount'
	FROM Employee
	WHERE RetireDate IS NULL --  16
;

SELECT COUNT(EmpID) AS 'EmpCount'
	FROM Employee
	WHERE RetireDate IS NULL --  16
;
	
SELECT COUNT(Salary) AS 'EmpCount'
	FROM Employee
	WHERE RetireDate IS NULL --  15
;


-- 근무 중인 직원들의 급여의 평균을 구하는 쿼리를 작성하고 있다. 
-- 다음 두 쿼리의 차이점을 설명하자.

SELECT SUM(Salary) / COUNT(EmpID) AS 'Avg_Salary'
	FROM Employee
	WHERE RetireDate IS NULL --  5,681
;

SELECT SUM(Salary) / COUNT(Salary) AS 'Avg_Salary'
	FROM Employee
	WHERE RetireDate IS NULL --  6,060
;

-- 참고 
SELECT AVG(Salary) AS 'Avg_Salary'
	FROM Employee
	WHERE RetireDate IS NULL --  6,060
;
 

-- 3) 그룹별 집계: GROUP BY

-- 부서별 근무 중인 직원 수 구하기
SELECT DeptID, COUNT(*) AS 'Emp_Count'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
;

-- 부적절한 GROUP BY 문: EmpName 이 GROUP BY에 없다. 그냥 제일 먼저 나오는 값을 보여준다.
SELECT DeptID, EmpName, COUNT(*) AS 'Emp_Count'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
    ORDER BY 1, 2
;
SELECT DeptID, EmpName FROM Employee ORDER BY 1, 2;

-- 부서별 근무하는 직원의 급여의 합을 구하자.
SELECT DeptID, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID 
;

-- 부서별 근무하는 직원의 최대값, 최소값, 최대값 - 최소값을 구하자
SELECT DeptID, MAX(Salary) AS 'Max_Salary', MIN(Salary) AS ' Min_Salary',
			 MAX(Salary) - MIN(Salary) AS ' Diff_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
;

--  부서별 근무하는 직원중 급여가 5000 이상인 직원의 수를구하자
SELECT DeptID, COUNT(EmpID) AS 'Max_Salary'
	FROM Employee
	WHERE Salary > 5000
	GROUP BY DeptID;
;


-- 4) 그룹핑 결과에 대한 필터링: HAVING

SELECT DeptID, COUNT(*) AS 'Emp_Count'
	FROM Employee
	GROUP BY DeptID
	HAVING COUNT(*) >= 3
;

-- 부서별로 현재 근무 중인 직원의 평균 급여를 얻는 쿼리를 작성하자.
SELECT DeptID, AVG(Salary) AS 'Avg_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
;

-- 위에서 얻은 부서 평균 급여가 전사 평균 급여보다 많은 부서의 평균 급여는?
SELECT DeptID, AVG(Salary) AS 'Avg_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
	HAVING AVG(Salary) > (SELECT AVG(Salary) FROM Employee WHERE RetireDate IS NULL)
;


-- 5) 새로운 그룹 별 집계 방법: GROUPING SETS

SELECT DeptID, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID
;

SELECT Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY Gender
;

-- 결과 결합
SELECT DeptID, NULL AS 'Gender', SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY DeptID

UNION

SELECT NULL, Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY Gender
	ORDER BY Gender, DeptID
;

/*
-- GROUPING SETS 사용
SELECT DeptID, Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE RetireDate IS NULL
	GROUP BY GROUPING SETS (DeptID, Gender)
	ORDER BY Gender, DeptID
;

-- 전체 집계만 보여주기
SELECT DeptID, Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
	GROUP BY GROUPING SETS((DeptID, Gender), ())
;

-- 부서 소계 + 전체 집계 보여주기
SELECT DeptID, Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
	GROUP BY GROUPING SETS((DeptID, Gender), (DeptID), ())
;

-- 부서 소계만 보여주기(전체 집계 생략)
SELECT DeptID, Gender, SUM(Salary) AS 'Tot_Salary'
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
	GROUP BY GROUPING SETS((DeptID, Gender), (DeptID))
;
*/


-- 
--  B. 순위 구하기
-- 


-- 1) 순위 표시: RANK

-- 전체 순위
SELECT EmpID, EmpName, Gender, Salary, @curRank := @curRank + 1 AS rank
FROM Employee e, (SELECT @curRank := 0) r
WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
order by Salary DESC
;


/*
-- 영역별 순위
SELECT EmpID, EmpName, Gender, Salary, 
	RANK() OVER(PARTITION BY Gender ORDER BY Salary DESC) AS 'Rnk'
   FROM Employee
   WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;
SELECT city, country, population
   FROM
     (SELECT city, country, population, 
                  @country_rank := IF(@current_country = country, @country_rank + 1, 1) AS country_rank,
                  @current_country := country 
       FROM cities
       ORDER BY country, population DESC
     ) ranked
   WHERE country_rank <= 2;
*/

-- 2) 순위 표시: DENSE_RANK

/*
-- 전체 순위
SELECT EmpID, EmpName, Gender, Salary,  DENSE_RANK() OVER(ORDER BY Salary DESC) AS 'Rnk'
   FROM Employee
   WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;
set @sno:=0; 
set @names:=''; 
select @sno:=case when @names=names then @sno else @sno+1 end as sno,@names:=names as names from test 
order by names;
*/

-- 영역별 순위
SELECT EmpID, EmpName, Gender, Salary, 
	DENSE_RANK() OVER(PARTITION BY Gender ORDER BY Salary DESC) AS 'Rnk'
   FROM Employee
   WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;


-- 3) 번호 표시: ROW_NUMBER

-- 전체 번호
SELECT ROW_NUMBER() OVER(ORDER BY EmpName DESC) AS 'Num',
			 EmpName, EmpID, Gender, Salary
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;

-- 영역별 번호
SELECT ROW_NUMBER() OVER(PARTITION BY DeptID
			 ORDER BY EmpName DESC) AS 'Num',
			 DeptID, EmpName, Empid, Gender, Salary
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;


-- 4) 범위 표시: NTILE

-- 전체 범위
SELECT EmpID, EmpName, Gender, Salary, NTILE(3) OVER(ORDER BY Salary DESC) AS 'Band'
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;

-- 영역별 범위
SELECT EmpID, EmpName, Gender, Salary, 
			 NTILE(3) OVER(PARTITION BY Gender ORDER BY Salary DESC) AS 'Band'
	FROM Employee
	WHERE DeptID IN ('SYS', 'MKT') AND RetireDate IS NULL
;



-- 
--  C. PIVOT과 UNPIVOT
-- 


-- 1) PIVOT

-- 부서 코드를 포함한 직원들의 휴가 현황
SELECT v.EmpID, e.DeptID, Year(v.BeginDate) AS 'Year', v.Duration
	FROM Vacation AS v
	INNER JOIN  Employee AS e ON v.EmpID = e.EmpID
;

-- 부서별 +연도별 휴가 현황 집계
SELECT e.DeptID, Year(v.BeginDate) AS 'Year', SUM(v.Duration) AS 'Duration'
	FROM Vacation AS v
	INNER JOIN  Employee AS e ON v.EmpID = e.EmpID
	GROUP BY e.DeptID, Year(BeginDate) 
;

/*
-- 피벗 형태로 표시하기
SELECT DeptID, [2007], [2008], [2009], [2010], [2011]
	FROM (
		SELECT e.DeptID, Year(v.BeginDate) AS 'Year', SUM(v.Duration) AS 'Duration'
			FROM Vacation AS v
			INNER JOIN  Employee AS e ON v.EmpID = e.EmpID
			GROUP BY e.DeptID, Year(BeginDate) 
	) AS Src
	PIVOT(SUM(Duration) 
	FOR Year IN([2007], [2008], [2009], [2010], [2011])) AS Pvt
;

-- 피벗 형태로 표시하기(NULL 값 처리)
SELECT DeptID, ISNULL([2007], 0) AS '2007', ISNULL([2008], 0) AS '2008', ISNULL([2009], 0) AS '2009', ISNULL([2010], 0) AS '2010', ISNULL([2011], 0) AS '2011'
	FROM (
		SELECT e.DeptID, Year(v.BeginDate) AS 'Year', SUM(v.Duration) AS 'Duration'
			FROM Vacation AS v
			INNER JOIN  Employee AS e ON v.EmpID = e.EmpID
			GROUP BY e.DeptID, Year(BeginDate) 
	) AS Src
	PIVOT(SUM(Duration) 
	FOR Year IN([2007], [2008], [2009], [2010], [2011])) AS Pvt
;


-- 2) UNPIVOT

 -- 피벗 형태 테이블 만들기
 SELECT DeptID, [2007], [2008], [2009], [2010], [2011]
	INTO YearVacation
	FROM (
		SELECT e.DeptID, Year(v.BeginDate) AS 'Year', SUM(v.Duration) AS 'Duration'
			FROM Vacation AS v
			INNER JOIN  Employee AS e ON v.EmpID = e.EmpID
			GROUP BY e.DeptID, Year(BeginDate) 
	) AS Src
	PIVOT(SUM(Duration) 
	FOR Year IN([2007], [2008], [2009], [2010], [2011])) AS Pvt
;

SELECT * FROM YearVacation
;

-- UNPIVOT
SELECT DeptID, Year, Duration
	FROM YearVacation
	UNPIVOT (Duration FOR Year IN ([2007], [2008], [2009], [2010], [2011])) AS uPvt
;
*/
