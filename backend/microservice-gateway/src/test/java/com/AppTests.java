package com;

import com.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
import org.springframework.http.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.io.BufferedReader;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

  @InjectMocks
  private AuthService authService;

  @Mock
  private RestTemplate restTemplate;

  @Mock
  private HttpServletRequest request;

  @BeforeEach
  void setUp() {
    MockitoAnnotations.openMocks(this);
    authService = new AuthService(restTemplate);
  }

  @Test
  void proxyRequest_shouldReturnSuccessResponse() throws Exception {
    String serviceName = "microservice-users";
    String body = "{\"key\":\"value\"}";

    // Simular HttpServletRequest
    when(request.getMethod()).thenReturn("POST");
    when(request.getRequestURI()).thenReturn("/gateway/users/test");
    when(request.getQueryString()).thenReturn("param=value");

    Enumeration<String> headerNames = Collections.enumeration(List.of("Content-Type"));
    when(request.getHeaderNames()).thenReturn(headerNames);
    when(request.getHeaders("Content-Type")).thenReturn(Collections.enumeration(List.of("application/json")));
    when(request.getReader()).thenReturn(new BufferedReader(new StringReader(body)));

    ResponseEntity<String> mockResponse = new ResponseEntity<>("OK", HttpStatus.OK);
    when(restTemplate.exchange(
            anyString(),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(String.class)
    )).thenReturn(mockResponse);

    ResponseEntity<Object> response = authService.proxyRequest(serviceName, request);

    assertEquals(HttpStatus.OK, response.getStatusCode());
    assertEquals("OK", response.getBody());
  }

  @Test
  void proxyRequest_shouldHandleHttpClientErrorException() throws Exception {
    String serviceName = "microservice-users";

    when(request.getMethod()).thenReturn("GET");
    when(request.getRequestURI()).thenReturn("/gateway/users/test");
    when(request.getQueryString()).thenReturn(null);
    when(request.getHeaderNames()).thenReturn(Collections.enumeration(Collections.emptyList()));
    when(request.getReader()).thenReturn(new BufferedReader(new StringReader("")));

    HttpHeaders errorHeaders = new HttpHeaders();
    errorHeaders.add("Error-Header", "SomeValue");

    HttpClientErrorException exception = HttpClientErrorException.create(
            HttpStatus.BAD_REQUEST,
            "Bad Request",
            errorHeaders,
            "Error Body".getBytes(),
            StandardCharsets.UTF_8
    );

    when(restTemplate.exchange(
            anyString(),
            eq(HttpMethod.GET),
            any(HttpEntity.class),
            eq(String.class)
    )).thenThrow(exception);

    ResponseEntity<Object> response = authService.proxyRequest(serviceName, request);

    assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
    assertEquals("Error Body", response.getBody());
    assertTrue(response.getHeaders().containsKey("Error-Header"));
  }

  @Test
  void proxyRequest_shouldHandleGenericException() throws Exception {
    String serviceName = "microservice-users";

    when(request.getMethod()).thenReturn("GET");
    when(request.getRequestURI()).thenReturn("/gateway/users/test");
    when(request.getQueryString()).thenReturn(null);
    when(request.getHeaderNames()).thenReturn(Collections.enumeration(Collections.emptyList()));
    when(request.getReader()).thenReturn(new BufferedReader(new StringReader("")));

    when(restTemplate.exchange(
            anyString(),
            eq(HttpMethod.GET),
            any(HttpEntity.class),
            eq(String.class)
    )).thenThrow(new RuntimeException("Unexpected error"));

    ResponseEntity<Object> response = authService.proxyRequest(serviceName, request);

    assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
    assertTrue(((String) response.getBody()).contains("Error en el gateway"));
  }
}
