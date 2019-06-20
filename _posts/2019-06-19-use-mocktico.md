---
layout: post
title: Use Mockito
disqus: y
share: y
categories: [Test]
tags: [Unit Test]
---

> Notice: All the numbers and cases in this page are fake number, just for example

## General Concept
Why need "MOCK", because there are many dependency for the software module. To better isolate the software layer, we need Mock.  
  
A typical case, A and B developing on-line cart function, A is doing DAO part, B is doing service part. Apparently, B is dependency on A's code, how B doing the unit test for his code? We can: 1.Insert trash data into DAO class ? That is so ugly. 2.Create the fake data? That just useless work, B will need write test again whey actual DAO is done. That's why the mock test tools come out, which let developer focus on their own unit code.

For Java, there are some mock frameworks: EasyMock, PowerMock, JMockit etc, the Mockito is most popular. Here is using Mockito as example.

## Examples
Let's check two examples I implemented and help me understand how mock works.

#### DAO Example
The DAO will do the query for database, however, consider we don't have final query yet, use @Mock to simulate the JdbcTemplate behavior, so the code will not actually call the db. Here we only check the query has been called, if we want to test the return data behavior, we can add when...thenReturn to simulate.
```java
@RunWith(SpringRunner.class)
public class TestDaoTest {

    @InjectMocks
    private TestDao testDao = new TestDao();

    @Mock
    private JdbcTemplate jdbcTemplate;

    @Captor
    private ArgumentCaptor<ResultSetExtractor<List<Integer>>> resultSetExtractorCaptor;

    private Long userIdMock;

    @Before
    public void setUp() {
        userIdMock = 33333L;
    }

    @Test
    public void getSelectedModalByUserIdTest() {
        testDao.getSelectedModalByUserId(userIdMock);

        //verify the query has been called
        verify(jdbcTemplate).queryForList(
                eq(Queries.GET_BB_SELECTED_MODAL_BY_USERID),
                refEq(new Object[] { userIdMock }),
                eq(Integer.class)
        );
    }
}
```

#### RESTFUL Example
This is a service layer case, the service will call the Restful API, however, the remote API is not completed yet. In order to do unit test the service logic, we can add mock RestTemplate to simulate the API call, then use the mock data to verify the unit(testService.getLocalTestData) logic.  
```java
RunWith(SpringRunner.class)
public class TestServiceTest {

    private static ObjectMapper objectMapper;

    @Mock
	//when use mock annotation, the data is in memory, it will not actually run the rest full call.
    private RestTemplate restTemplate;

    @Mock
	//when use mock annotation, the data is in memory, it will not actually run the database query.
    private TestDao testDao = new TestDao();

    @InjectMocks
	//InjectMocks allow us to inject the Mock object into the target object, so when the testService is using restTemplate, the test will able to catch it.
    private TestService testService = new TestService();

    @Captor
	//Captor will able to pass the object to parameter
    private ArgumentCaptor<HttpEntity<TestPDFDownloadParameter>> httpEntityDwnParameterCaptor;

    private final static String MOCK_API_URL = "http://localhost/test-api";
    private final static String MOCK_GET_PDF_DATA = "ser/getTestPdfData";
    private Long userIdMock;
    private Long companyIdMock;
    @Before
    public void init() {
		/*
	     * setField will allow us inject / replace the attribute for target object.		
		 * public static void setField(Object targetObject, String name, Object value) {
         *   setField((Object)targetObject, name, value, (Class)null);
         * }
		 *
        ReflectionTestUtils.setField(testService, "API_URL", MOCK_API_URL);
        ReflectionTestUtils.setField(testService, "GET_PDF_DATA", MOCK_GET_PDF_DATA);

        userIdMock = 37817L;
        companyIdMock = 244L;

        /* 
		 * return true for isOurUser mock
		 *
		 * the testDao.isOurUser is used inside the testService, use when...thenReturn to mock,
		 * every time the testDao.isOurUser is been called, will return true.
		 */
        when(testDao.isOurUser(userIdMock)).thenReturn(true);
    }

    @Test
    public void getLocalTestDataTest() {
        testService.getLocalTestData(userIdMock, companyIdMock);
        String mockUrl = (MOCK_API_URL + "/" + MOCK_GET_PDF_DATA).trim();

        //verify the exchange has been called once, this just verify the exchange function has been called with required parameter
        verify(restTemplate, times(1)).exchange(
                eq(mockUrl),
                eq(HttpMethod.POST),
                httpEntityDwnParameterCaptor.capture(),
                eq(String.class)
        );

        // verify the post payload, Mocktico is able to catch parameters
        HttpEntity<TestPDFDownloadParameter> capturedRequest = httpEntityDwnParameterCaptor.getValue();
        String contentType = capturedRequest.getHeaders().get(HttpHeaders.CONTENT_TYPE).get(0);
        assertEquals("application/json", contentType);

        // verify the payload detail value, below is just using the Junit to verify the data point
        TestPDFDownloadParameter o = capturedRequest.getBody();
        assertFalse(o.getIsCustomPeerGroup());
        assertEquals(userIdMock, o.getInsightUserId());
        assertEquals(Integer.valueOf(2), o.getPeerGroupId());
        assertTrue(o.getIsDetailSelected());
        assertTrue(o.getIsSummarySelected());
        assertEquals("Test", o.getProductLogoCode());
        assertEquals("Report", o.getReportAccessType());
        assertNull(o.getUserEnteredTickers());
    }
}
```

## Think
It is very tricky when I first time touch mock since I always verify data with actually data. Just keep in mind, the purpose of mock is focus on unit logic itself, any dependency can be mocked.

## Reference
[Unit tests with Mockito - Tutorial](https://www.vogella.com/tutorials/Mockito/article.html)
[Mockito使用指南 - 单元测试的正确姿势](http://blog.hanschen.site/2016/06/21/mockito.html)