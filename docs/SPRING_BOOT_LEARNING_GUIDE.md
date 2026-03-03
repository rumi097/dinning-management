# Java & Spring Boot — Complete Learning Guide (From Zero)

> **Who is this for?** You — a developer who doesn't know Java yet and wants to understand Spring Boot from scratch, then understand your DSI RUET project completely.
>
> **How to read this?** Start from Chapter 1 and go in order. Every chapter builds on the previous one. Don't skip.

---

## Table of Contents

- **Part 1: Java Fundamentals** (Chapters 1–7)
- **Part 2: Spring Boot Fundamentals** (Chapters 8–16.5)
  - Chapter 16.5: **Spring Boot Syntax — Complete Reference** (15 syntax templates)
- **Part 3: Your Project Explained** (Chapters 17–22)

---

# PART 1: JAVA FUNDAMENTALS

---

## Chapter 1: What is Java?

Java is a programming language. When you write Java code, it gets **compiled** into bytecode, then runs on the **JVM** (Java Virtual Machine). The JVM exists for every operating system (Mac, Windows, Linux), so your code runs everywhere.

### 1.1 — Your first Java program

```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, world!");
    }
}
```

Let's break this down word by word:

| Word | Meaning |
|------|---------|
| `public` | Anyone can access this (visibility) |
| `class` | A blueprint/template (Java organizes everything in classes) |
| `Hello` | The name of the class (must match the filename: `Hello.java`) |
| `{` `}` | Everything inside these braces belongs to this class |
| `static` | This method belongs to the class itself, not to an instance |
| `void` | This method doesn't return any value |
| `main` | The entry point — Java starts running from here |
| `String[] args` | Command-line arguments (ignore for now) |
| `System.out.println()` | Built-in function to print text to the console |

### 1.2 — Key rule: Everything in Java lives inside a class

Unlike Python or JavaScript, you can't just write code in a file. ALL code must be inside a class.

```java
// ❌ This is NOT valid Java
int x = 5;
System.out.println(x);

// ✅ This IS valid Java
public class MyProgram {
    public static void main(String[] args) {
        int x = 5;
        System.out.println(x);
    }
}
```

---

## Chapter 2: Variables and Data Types

### 2.1 — Java is "statically typed"

In Python/JavaScript, you just write `x = 5`. In Java, you must declare the TYPE first:

```java
int age = 21;              // integer (whole number)
double price = 60.5;       // decimal number
String name = "Rumi";      // text (note: capital S)
boolean isStudent = true;  // true or false
long bigNumber = 999999L;  // big integer
```

### 2.2 — Primitive types vs Objects

| Primitive (lowercase) | Object (uppercase) | Difference |
|----------------------|-------------------|------------|
| `int` | `Integer` | Primitive is simpler, faster |
| `double` | `Double` | Object version can be `null` |
| `boolean` | `Boolean` | Object version is used in collections |
| `long` | `Long` | Object version is used in databases |

**Why this matters for your project**: Databases can have NULL values. Java primitive `int` can NEVER be null, but `Integer` can. That's why your entities use `Long id` (not `long id`) — because the ID is null before the entity is saved to the database.

```java
Long id;            // can be null (before saving to DB)
long id;            // CANNOT be null — would crash
```

### 2.3 — String

```java
String greeting = "Hello";
String name = "Rumi";

// Concatenation
String message = greeting + ", " + name + "!";  // "Hello, Rumi!"

// String methods
int length = name.length();        // 4
boolean eq = name.equals("Rumi");  // true (use .equals(), NOT ==)
String upper = name.toUpperCase(); // "RUMI"
```

**CRITICAL**: In Java, comparing strings with `==` checks if they're the SAME OBJECT, not the same text. Always use `.equals()`:

```java
// ❌ WRONG
if (name == "Rumi") { ... }

// ✅ CORRECT
if (name.equals("Rumi")) { ... }
```

---

## Chapter 3: Control Flow

### 3.1 — If/else

```java
int age = 21;

if (age >= 18) {
    System.out.println("Adult");
} else if (age >= 13) {
    System.out.println("Teenager");
} else {
    System.out.println("Child");
}
```

### 3.2 — For loop

```java
// Classic for loop
for (int i = 0; i < 5; i++) {
    System.out.println(i);  // prints 0, 1, 2, 3, 4
}

// Enhanced for-each loop (used A LOT in Spring Boot)
List<String> names = List.of("Rumi", "Karim", "Tanvir");
for (String name : names) {
    System.out.println(name);
}
```

### 3.3 — Switch

```java
String mealType = "LUNCH";

switch (mealType) {
    case "LUNCH":
        System.out.println("It's lunch");
        break;
    case "DINNER":
        System.out.println("It's dinner");
        break;
    default:
        System.out.println("Unknown meal");
}
```

---

## Chapter 4: Methods (Functions)

In Java, functions are called **methods** and they always live inside a class.

### 4.1 — Basic method

```java
public class Calculator {

    // Method that takes two ints and returns an int
    public int add(int a, int b) {
        return a + b;
    }

    // Method that returns nothing (void)
    public void greet(String name) {
        System.out.println("Hello, " + name);
    }

    // Method that returns a boolean
    public boolean isAdult(int age) {
        return age >= 18;
    }
}
```

### 4.2 — Calling methods

```java
Calculator calc = new Calculator();  // Create an object (instance)
int result = calc.add(5, 3);        // result = 8
calc.greet("Rumi");                  // prints "Hello, Rumi"
boolean adult = calc.isAdult(21);    // adult = true
```

### 4.3 — Static methods

Static methods belong to the CLASS, not to an instance. You don't need to create an object with `new`:

```java
public class MathHelper {
    public static int square(int x) {
        return x * x;
    }
}

// Call without creating an object
int result = MathHelper.square(5);  // 25
```

**In your project**: `ApiResponse.success(data, "message")` is a static method. You call it directly on the class without creating an `ApiResponse` object first.

---

## Chapter 5: Classes and Objects (OOP)

This is the most important concept for understanding Spring Boot.

### 5.1 — What is a class?

A class is a **blueprint**. An object is a **thing built from that blueprint**.

```java
// Blueprint
public class Student {
    String name;
    int roll;
    String hall;
}

// Creating objects (instances) from the blueprint
Student s1 = new Student();
s1.name = "Rumi";
s1.roll = 2003045;
s1.hall = "Shaheed Abdur Rab Hall";

Student s2 = new Student();
s2.name = "Karim";
s2.roll = 2003046;
s2.hall = "Shaheed Abdur Rab Hall";
```

### 5.2 — Constructor

A constructor is a special method that runs when you create an object:

```java
public class Student {
    String name;
    int roll;

    // Constructor
    public Student(String name, int roll) {
        this.name = name;     // "this" refers to the object being created
        this.roll = roll;
    }
}

// Now creation is cleaner
Student s1 = new Student("Rumi", 2003045);
```

### 5.3 — Getters and Setters

In Java, fields are usually `private` (can't be accessed directly). You use getter/setter methods:

```java
public class Student {
    private String name;    // private = can only be accessed inside this class
    private int roll;

    // Getter
    public String getName() {
        return this.name;
    }

    // Setter
    public void setName(String name) {
        this.name = name;
    }

    // Getter
    public int getRoll() {
        return this.roll;
    }

    // Setter
    public void setRoll(int roll) {
        this.roll = roll;
    }
}

// Usage
Student s = new Student();
s.setName("Rumi");              // use setter
String name = s.getName();      // use getter
```

This is very tedious. That's why your project uses **Lombok** (Chapter 6).

### 5.4 — Inheritance

A class can extend another class to inherit its fields and methods:

```java
public class Person {
    String name;
    int age;
}

public class Student extends Person {
    int roll;        // Student has name + age (inherited) + roll (its own)
    String hall;
}
```

### 5.5 — Interfaces

An interface is a contract — it says "any class implementing me MUST have these methods":

```java
// Interface (contract)
public interface Printable {
    void print();    // No body — implementing classes must provide the body
}

// Implementation
public class Invoice implements Printable {
    @Override
    public void print() {
        System.out.println("Printing invoice...");
    }
}
```

**In your project**: `JpaRepository` is an interface. When you write `public interface UserRepository extends JpaRepository<User, Long>`, Spring automatically creates the implementation for you.

---

## Chapter 6: Lombok — Skip the Boilerplate

Lombok is a library that **generates** getters, setters, constructors, and more at compile time using annotations.

### 6.1 — Without Lombok (painful)

```java
public class User {
    private Long id;
    private String name;
    private String email;

    public User() {}

    public User(Long id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    @Override
    public String toString() { ... }

    @Override
    public boolean equals(Object o) { ... }

    @Override
    public int hashCode() { ... }
}
```

That's 40+ lines just for 3 fields!

### 6.2 — With Lombok (your project uses this)

```java
@Data                    // generates getters, setters, toString, equals, hashCode
@NoArgsConstructor       // generates empty constructor: User()
@AllArgsConstructor      // generates constructor with all fields: User(id, name, email)
@Builder                 // generates builder pattern (explained below)
public class User {
    private Long id;
    private String name;
    private String email;
}
```

**Same functionality, 10 lines instead of 40+.**

### 6.3 — Lombok annotations in your project

| Annotation | What it generates |
|-----------|------------------|
| `@Data` | `getName()`, `setName()`, `toString()`, `equals()`, `hashCode()` for ALL fields |
| `@NoArgsConstructor` | `new User()` — empty constructor |
| `@AllArgsConstructor` | `new User(id, name, email)` — all-fields constructor |
| `@Builder` | `User.builder().name("Rumi").email("rumi@...").build()` — builder pattern |
| `@RequiredArgsConstructor` | Constructor for `final` fields only (used for dependency injection) |
| `@Slf4j` | Creates a `log` variable for logging: `log.info("message")` |

### 6.4 — The Builder pattern

```java
// Without builder (awkward with many fields)
User user = new User(null, "rumi@student.ruet.ac.bd", "pass123", "Rumi", hall1, false, Role.STUDENT);
// Which argument is which? Hard to read!

// With builder (clear and readable)
User user = User.builder()
        .email("rumi@student.ruet.ac.bd")
        .password("pass123")
        .name("Rumi")
        .hall(hall1)
        .isVerified(true)
        .role(Role.STUDENT)
        .build();
// Every field is labeled — easy to read!
```

Your `DataSeeder.java` uses builders everywhere:

```java
Hall hall1 = hallRepository.save(Hall.builder().name("Shaheed Abdur Rab Hall").build());
```

### 6.5 — @RequiredArgsConstructor (important for services)

```java
@Service
@RequiredArgsConstructor  // generates constructor for 'final' fields
public class MarketplaceService {
    private final MarketplaceRepository marketplaceRepository;  // final = must be set
    private final TokenRepository tokenRepository;              // final = must be set

    // Lombok generates this constructor automatically:
    // public MarketplaceService(MarketplaceRepository marketplaceRepository,
    //                           TokenRepository tokenRepository) {
    //     this.marketplaceRepository = marketplaceRepository;
    //     this.tokenRepository = tokenRepository;
    // }
}
```

Spring Boot uses this constructor to **inject** (pass in) the dependencies automatically. More on this in Chapter 11.

---

## Chapter 7: Java Collections and Streams

### 7.1 — List (ordered collection)

```java
import java.util.List;
import java.util.ArrayList;

// Create a list
List<String> names = new ArrayList<>();
names.add("Rumi");
names.add("Karim");
names.add("Tanvir");

// Access by index
String first = names.get(0);    // "Rumi"

// Size
int count = names.size();       // 3

// Loop
for (String name : names) {
    System.out.println(name);
}

// Check if contains
boolean hasRumi = names.contains("Rumi");  // true
```

### 7.2 — Map (key-value pairs)

```java
import java.util.Map;
import java.util.HashMap;

Map<String, Integer> balances = new HashMap<>();
balances.put("Rumi",   500);
balances.put("Karim",  300);

int rumiBalance = balances.get("Rumi");  // 500
```

### 7.3 — Optional (may or may not have a value)

This is used A LOT in Spring Data JPA. A database query might find a result or not.

```java
import java.util.Optional;

// findById returns Optional — it might be empty
Optional<User> maybeUser = userRepository.findById(5L);

// Way 1: Check if present
if (maybeUser.isPresent()) {
    User user = maybeUser.get();
    System.out.println(user.getName());
}

// Way 2: Use orElseThrow (your project does this)
User user = userRepository.findById(5L)
        .orElseThrow(() -> new MarketplaceException("User not found: " + 5));
```

In your project's `MarketplaceService.java`:
```java
private User findUserOrThrow(Long userId) {
    return userRepository.findById(userId)
            .orElseThrow(() -> new MarketplaceException("User not found: " + userId));
}
```

### 7.4 — Streams and Lambda (modern Java)

Streams let you process collections in a functional style:

```java
List<MarketplacePost> posts = repository.findAll();

// Convert each post to a response DTO
List<MarketplacePostResponse> responses = posts
        .stream()                    // start a stream
        .map(this::toResponse)       // apply toResponse() to each element
        .collect(Collectors.toList()); // collect results into a List
```

Breaking down the syntax:

```java
// Lambda (anonymous function)
(post) -> toResponse(post)     // full form
this::toResponse               // shorthand (method reference)

// Filter — keep only elements that match a condition
List<User> adults = users.stream()
        .filter(user -> user.getAge() >= 18)  // lambda: true = keep, false = discard
        .collect(Collectors.toList());
```

Your `MarketplaceService` uses this pattern in almost every query method:

```java
return marketplaceRepository.findByStatusAndHallId(MarketplacePostStatus.OPEN, hallId)
        .stream()                      // turn the list into a stream
        .map(this::toResponse)         // convert each MarketplacePost → MarketplacePostResponse
        .collect(Collectors.toList()); // collect back into a list
```

### 7.5 — Arrays (helper class)

```java
import java.util.Arrays;

// Create a list from values
List<MarketplacePostStatus> statuses = Arrays.asList(
    MarketplacePostStatus.OPEN,
    MarketplacePostStatus.PENDING
);
```

---

## Chapter 7.5: Enums

An enum is a fixed set of constants:

```java
public enum MealType {
    LUNCH,
    DINNER
}

// Usage
MealType type = MealType.LUNCH;

if (type == MealType.LUNCH) {
    System.out.println("It's lunch time");
}

// Get the string representation
String name = type.name();  // "LUNCH"
```

Your project has 5 enums: `Role`, `MealType`, `TokenStatus`, `TransactionType`, `MarketplacePostStatus`.

---

# PART 2: SPRING BOOT FUNDAMENTALS

---

## Chapter 8: What is Spring Boot?

### 8.1 — The problem it solves

Without Spring Boot, to create a web server in Java you'd need to:
1. Install and configure a Tomcat server manually
2. Write XML configuration files (hundreds of lines)
3. Manually create database connections
4. Manually manage object lifecycles
5. Write tons of plumbing code

Spring Boot does ALL of this for you with **zero configuration** — you just write your business logic.

### 8.2 — What happens when you run your app?

When you run `./mvnw spring-boot:run`, this happens:

```
1. Maven reads pom.xml → downloads all dependencies
2. Java compiler compiles your .java files → .class files
3. Spring Boot starts:
   a. Creates an embedded Tomcat web server (port 8080)
   b. Scans ALL your classes for annotations (@Service, @Controller, etc.)
   c. Creates ONE instance of each annotated class and stores them in a "container"
   d. Reads application.properties → configures database connection
   e. Hibernate reads your @Entity classes → creates/updates database tables
   f. DataSeeder runs (CommandLineRunner)
   g. Server is ready → listening for HTTP requests on port 8080
```

### 8.3 — The annotation-driven approach

Spring Boot works through **annotations** — special markers starting with `@` that tell Spring what to do with your classes:

```java
@SpringBootApplication  → "This is the starting point of the app"
@Entity                 → "This class maps to a database table"
@Service                → "This class contains business logic"
@RestController         → "This class handles HTTP requests"
@Repository             → "This class talks to the database"
```

You put the annotation on the class, and Spring Boot does the wiring for you.

---

## Chapter 9: The POM File — Your Project's Shopping List

### 9.1 — What is Maven?

Maven is a **build tool** for Java. It does three things:
1. **Downloads libraries** you need (called "dependencies")
2. **Compiles** your Java code
3. **Packages** your app into a runnable JAR file

### 9.2 — What is `pom.xml`?

POM = Project Object Model. It's your project's configuration file. Think of it as `package.json` (Node) or `pubspec.yaml` (Flutter) — it lists what your project needs.

### 9.3 — Your `pom.xml` explained line by line

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project>
```
Standard XML declaration — every `pom.xml` starts this way.

```xml
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>4.0.3</version>
    </parent>
```
**Parent POM**: Your project inherits from `spring-boot-starter-parent`. This parent:
- Sets default configurations for 100+ things
- Manages version numbers for all Spring libraries
- So you don't have to specify versions for each Spring dependency

Think of it as: "I'm building ON TOP of Spring Boot 4.0.3".

```xml
    <groupId>dsi.ruet</groupId>
    <artifactId>backend</artifactId>
    <version>0.0.1-SNAPSHOT</version>
```
**Your project's identity**:
- `groupId` = your organization (like a domain name reversed). `dsi.ruet` = DSI at RUET.
- `artifactId` = project name. `backend` = this is the backend module.
- `version` = current version. `0.0.1-SNAPSHOT` means "still in development."

```xml
    <properties>
        <java.version>21</java.version>
    </properties>
```
Tells Maven to use Java 21 for compilation.

```xml
    <dependencies>
        <!-- EACH DEPENDENCY IS A LIBRARY YOUR PROJECT NEEDS -->
    </dependencies>
```
Here's where you list your "shopping list" of libraries.

### 9.4 — Each dependency explained

#### Dependency #1: `spring-boot-starter-data-jpa`
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```
**What it gives you**:
- Hibernate ORM (maps Java objects ↔ database tables)
- JPA (Java Persistence API) — the standard for database access
- `@Entity`, `@Table`, `@Column` annotations
- `JpaRepository` interface (auto-generated CRUD methods)
- `@Transactional` support
- Database connection pooling (HikariCP)

**Without this**: You'd write raw SQL queries, manually open/close database connections, manually map result rows to Java objects. Nightmare.

#### Dependency #2: `spring-boot-starter-webmvc`
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc</artifactId>
</dependency>
```
**What it gives you**:
- Embedded Tomcat web server
- `@RestController`, `@GetMapping`, `@PostMapping` annotations
- JSON serialization/deserialization (Jackson library))
- CORS support
- Request/response handling

**Without this**: You'd need to install Tomcat separately, write servlet configuration XML, manually parse HTTP request bodies, manually convert Java objects to JSON.

#### Dependency #3: `postgresql`
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```
**What it gives you**: The PostgreSQL JDBC driver — lets Java talk to PostgreSQL databases.

`scope=runtime`: This driver is only needed when the app is RUNNING, not during compilation. During compilation, Hibernate talks to the generic JPA interface. At runtime, it uses this driver to actually connect to PostgreSQL.

#### Dependency #4: `lombok`
```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```
**What it gives you**: `@Data`, `@Builder`, `@RequiredArgsConstructor`, `@Slf4j` — code generation to skip boilerplate (Chapter 6).

`optional=true`: If someone else uses YOUR project as a dependency, they don't get Lombok automatically. It's optional for downstream users.

### 9.5 — The build section

```xml
<build>
    <plugins>
        <plugin>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
```
Tells the Java compiler: "When compiling, run Lombok's annotation processor to generate code for `@Data`, `@Builder`, etc."

```xml
        <plugin>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <excludes>
                    <exclude>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                    </exclude>
                </excludes>
            </configuration>
        </plugin>
```
The Spring Boot Maven plugin packages your app into a runnable JAR. It excludes Lombok from the final JAR because Lombok only generates code at compile-time — it's not needed at runtime.

### 9.6 — How to add a new dependency

If you need a new library, add it to the `<dependencies>` section:

```xml
<!-- Example: adding Spring Security for JWT auth later -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

Then Maven automatically downloads it when you compile: `./mvnw compile`.

### 9.7 — Maven commands you need

```bash
./mvnw compile              # Compile your code (check for errors)
./mvnw spring-boot:run      # Compile + start the server
./mvnw clean                # Delete all compiled files (target/ folder)
./mvnw clean compile        # Clean + recompile from scratch
./mvnw package              # Compile + create a runnable JAR file
```

`./mvnw` is the **Maven Wrapper** — a script included in your project so everyone on the team uses the same Maven version.

---

## Chapter 10: Project Structure — Where Everything Lives

```
backend/
├── pom.xml                              ← DEPENDENCY LIST (Chapter 9)
├── mvnw                                 ← Maven wrapper script (Mac/Linux)
├── mvnw.cmd                             ← Maven wrapper script (Windows)
│
├── src/
│   ├── main/                            ← YOUR APPLICATION CODE
│   │   ├── java/dsi/ruet/backend/       ← Java source files
│   │   │   ├── BackendApplication.java  ← ENTRY POINT
│   │   │   ├── models/                  ← Database entities
│   │   │   ├── repositories/            ← Database queries
│   │   │   ├── marketplace/             ← Feature module
│   │   │   ├── common/                  ← Shared utilities
│   │   │   └── seeder/                  ← Demo data
│   │   └── resources/
│   │       └── application.properties   ← CONFIGURATION
│   │
│   └── test/                            ← TEST CODE
│       └── java/                        ← Unit/integration tests
│
└── target/                              ← COMPILED OUTPUT (generated, not committed)
    └── classes/                         ← Compiled .class files
```

### 10.1 — Why this exact structure?

Maven requires this structure:
- `src/main/java/` → your application code (MUST be here)
- `src/main/resources/` → config files (MUST be here)
- `src/test/java/` → tests (MUST be here)
- `target/` → generated by Maven (NEVER commit this)

### 10.2 — The package structure

```
dsi/ruet/backend/
```

This is your **base package**. The `@SpringBootApplication` annotation on `BackendApplication.java` tells Spring: "Scan this package and ALL sub-packages for annotated classes."

```
dsi.ruet.backend                    ← BackendApplication lives here
dsi.ruet.backend.models             ← Hall, User, Token, etc.
dsi.ruet.backend.models.enums       ← Role, MealType, etc.
dsi.ruet.backend.repositories       ← HallRepository, UserRepository, etc.
dsi.ruet.backend.marketplace        ← Everything marketplace
dsi.ruet.backend.common             ← Shared utilities
dsi.ruet.backend.seeder             ← Demo data
```

Spring scans ALL of these because they're all under `dsi.ruet.backend`.

**IMPORTANT**: If you created a class in package `com.other.package`, Spring would NOT find it because it's not under `dsi.ruet.backend`. Always keep your code under the base package.

---

## Chapter 11: Dependency Injection — The Core Concept

This is THE most important concept in Spring Boot. Everything else builds on this.

### 11.1 — The problem

Your `MarketplaceController` needs a `MarketplaceService`. Your `MarketplaceService` needs a `MarketplaceRepository`. Your repository needs a database connection.

Without Spring, you'd manually create everything:

```java
// ❌ Without Spring — YOU manage everything
DataSource ds = new PostgreSQLDataSource("localhost", 5432, "dsiApp");
MarketplaceRepository repo = new MarketplaceRepositoryImpl(ds);
TokenRepository tokenRepo = new TokenRepositoryImpl(ds);
UserRepository userRepo = new UserRepositoryImpl(ds);
MarketplaceService service = new MarketplaceService(repo, tokenRepo, userRepo);
MarketplaceController controller = new MarketplaceController(service, userRepo);
```

This is a nightmare when you have 50+ classes.

### 11.2 — The solution: Dependency Injection (DI)

With Spring, you just put annotations on your classes, and Spring creates and connects everything automatically:

```java
@Repository          // "Spring, please create one instance of this"
public interface MarketplaceRepository extends JpaRepository<...> { }

@Service             // "Spring, please create one instance of this and inject its dependencies"
@RequiredArgsConstructor
public class MarketplaceService {
    private final MarketplaceRepository marketplaceRepository;  // Spring injects this
    private final TokenRepository tokenRepository;              // Spring injects this
    private final UserRepository userRepository;                // Spring injects this
}

@RestController      // "Spring, please create one instance of this and inject its dependencies"
@RequiredArgsConstructor
public class MarketplaceController {
    private final MarketplaceService service;    // Spring injects this
    private final UserRepository userRepository; // Spring injects this
}
```

### 11.3 — How injection works

```
           Spring Container (creates and stores all beans)
           ┌─────────────────────────────────────────────────┐
           │                                                 │
           │   HallRepository ──────────┐                    │
           │   UserRepository ──────────┼─→ MarketplaceService ─→ MarketplaceController
           │   TokenRepository ─────────┤                    │
           │   MarketplaceRepository ───┘                    │
           │   TokenTransactionRepository                    │
           │                                                 │
           └─────────────────────────────────────────────────┘
```

1. Spring finds all classes with `@Service`, `@Repository`, `@Controller`, `@Component`
2. Creates ONE instance of each (called a **bean**)
3. Looks at each bean's constructor
4. Fills in the required dependencies from other beans
5. Stores everything in the **Application Context** (the container)

### 11.4 — The annotation hierarchy

```
@Component              ← base annotation: "create a bean from this class"
    ├── @Service        ← same as @Component, but signals "I'm a service"
    ├── @Repository     ← same as @Component, but signals "I'm a data access layer"
    ├── @Controller     ← same as @Component, but signals "I handle web requests"
    └── @RestController ← @Controller + "return JSON by default"
```

They all do the same thing (register a bean), but using specific ones makes your code self-documenting.

---

## Chapter 12: Entities — Mapping Java Classes to Database Tables

### 12.1 — What is JPA?

JPA (Java Persistence API) is a standard that says: "Here's how you define which Java class maps to which database table." Hibernate is the most popular IMPLEMENTATION of JPA.

### 12.2 — Basic entity

```java
@Entity                              // "This class maps to a database table"
@Table(name = "halls")               // "The table is called 'halls'"
public class Hall {

    @Id                              // "This field is the primary key"
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // "Auto-increment"
    private Long id;

    @Column(nullable = false, unique = true)  // "NOT NULL, UNIQUE"
    private String name;
}
```

This generates the SQL:
```sql
CREATE TABLE halls (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);
```

### 12.3 — Column annotations

| Annotation | SQL equivalent | Example |
|-----------|---------------|---------|
| `@Column(nullable = false)` | `NOT NULL` | Name must have a value |
| `@Column(unique = true)` | `UNIQUE` | Email must be unique |
| `@Column(name = "pass")` | Column named "pass" | When Java field name ≠ DB column name |
| `@Column(columnDefinition = "TEXT")` | `TEXT` type | For long text (menu descriptions) |
| No @Column | Defaults to field name | `private String name` → column `name` |

### 12.4 — Relationship annotations

#### `@ManyToOne` — Many entities point to one entity

```java
// In User.java: Many users belong to one hall
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "hall_id", nullable = false)
private Hall hall;
```

This creates a `hall_id` foreign key column in the `users` table.

```sql
-- Generated SQL
ALTER TABLE users ADD COLUMN hall_id BIGINT NOT NULL REFERENCES halls(id);
```

**`FetchType.LAZY`**: Don't load the hall data from the database until you actually access `user.getHall()`. This is a performance optimization — if you only need the user's name, why load the entire hall object?

#### `@OneToOne` — One entity maps to exactly one other entity

```java
// In Wallet.java: One wallet per user
@OneToOne(fetch = FetchType.LAZY)
@MapsId                           // Share the same primary key as User
@JoinColumn(name = "id")
private User user;
```

`@MapsId` means the wallet's `id` IS the user's `id`. They share the same primary key. This is the strongest form of 1:1 relationship.

### 12.5 — Enum mapping

```java
@Enumerated(EnumType.STRING)    // Store as text: "LUNCH", "DINNER"
@Column(nullable = false)
private MealType mealType;
```

`EnumType.STRING` stores the enum value as a readable string ("LUNCH") in the database.

Alternative: `EnumType.ORDINAL` stores the position number (0, 1). **Never use ORDINAL** — if you reorder the enum values, your database breaks.

### 12.6 — `@PrePersist` — Run code before saving

```java
@PrePersist
protected void onCreate() {
    if (this.createdAt == null) {
        this.createdAt = LocalDateTime.now();
    }
    if (this.status == null) {
        this.status = TokenStatus.AVAILABLE;
    }
}
```

This method runs automatically RIGHT BEFORE the entity is saved to the database for the first time. It sets default values.

### 12.7 — Unique constraints

```java
@Table(name = "tokens", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"owner_id", "meal_id"})
})
```

This means the COMBINATION of `owner_id` + `meal_id` must be unique. A student can't own two tokens for the same meal. Each individual column can have duplicates, but the pair can't.

```sql
-- Generated SQL
ALTER TABLE tokens ADD CONSTRAINT ... UNIQUE (owner_id, meal_id);
```

### 12.8 — How `ddl-auto=update` works

In your `application.properties`:
```properties
spring.jpa.hibernate.ddl-auto=update
```

When Spring Boot starts:
1. Hibernate reads ALL your `@Entity` classes
2. Compares them to the actual database tables
3. If a table doesn't exist: `CREATE TABLE ...`
4. If you added a new field: `ALTER TABLE ... ADD COLUMN ...`
5. If you removed a field: does NOTHING (it doesn't delete columns — safety)
6. If you changed a type: tries to alter (may fail)

| `ddl-auto` value | What it does | When to use |
|------------------|-------------|-------------|
| `update` | Creates/updates tables, never deletes | Development (your current setting) |
| `create` | Drops ALL tables and recreates on every startup | Testing (destroys data!) |
| `create-drop` | Creates tables on start, drops on shutdown | Unit tests |
| `validate` | Checks tables match entities, throws error if not | Production |
| `none` | Does nothing | Production (use migration tools instead) |

---

## Chapter 13: Repositories — Talking to the Database

### 13.1 — What is a Repository?

A repository is a class that handles all database operations (CRUD) for a specific entity. In Spring Data JPA, you don't write the implementation — Spring generates it from the interface.

### 13.2 — Basic repository

```java
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    //                                              ↑      ↑
    //                                         Entity  Primary Key type
}
```

That's it. By extending `JpaRepository<User, Long>`, you get these methods FOR FREE:

| Method | What it does | SQL equivalent |
|--------|-------------|----------------|
| `save(user)` | Insert or update | `INSERT INTO users ... / UPDATE users SET ...` |
| `findById(5L)` | Find by primary key | `SELECT * FROM users WHERE id = 5` |
| `findAll()` | Get all records | `SELECT * FROM users` |
| `deleteById(5L)` | Delete by primary key | `DELETE FROM users WHERE id = 5` |
| `delete(user)` | Delete an entity | `DELETE FROM users WHERE id = ?` |
| `count()` | Count records | `SELECT COUNT(*) FROM users` |
| `existsById(5L)` | Check existence | `SELECT EXISTS(SELECT 1 FROM users WHERE id = 5)` |

### 13.3 — Derived queries (magic method names)

Spring can generate queries from method names:

```java
public interface UserRepository extends JpaRepository<User, Long> {

    // Spring reads the method name and generates the query!
    Optional<User> findByEmail(String email);
    // → SELECT * FROM users WHERE email = ?

    boolean existsByEmail(String email);
    // → SELECT EXISTS(SELECT 1 FROM users WHERE email = ?)

    List<User> findByHallId(Long hallId);
    // → SELECT * FROM users WHERE hall_id = ?

    List<User> findByRoleAndHallId(Role role, Long hallId);
    // → SELECT * FROM users WHERE role = ? AND hall_id = ?
}
```

**How does this work?** Spring parses the method name:
- `findBy` → start a SELECT query
- `Email` → WHERE email = ?
- `And` → AND
- `HallId` → hall_id = ?
- `existsBy` → SELECT EXISTS(...)

| Keyword | Example | SQL |
|---------|---------|-----|
| `findBy` | `findByName(name)` | `WHERE name = ?` |
| `And` | `findByNameAndAge(name, age)` | `WHERE name = ? AND age = ?` |
| `Or` | `findByNameOrEmail(name, email)` | `WHERE name = ? OR email = ?` |
| `OrderBy` | `findByHallIdOrderByNameAsc(hallId)` | `WHERE hall_id = ? ORDER BY name ASC` |
| `In` | `findByStatusIn(statuses)` | `WHERE status IN (?, ?, ?)` |
| `existsBy` | `existsByEmail(email)` | `EXISTS(... WHERE email = ?)` |
| `countBy` | `countByHallId(hallId)` | `SELECT COUNT(*) WHERE hall_id = ?` |

### 13.4 — Custom JPQL queries

When method names get too complex, you write JPQL (Java Persistence Query Language) — it's like SQL but uses class/field names instead of table/column names:

```java
@Query("SELECT p FROM MarketplacePost p " +
       "JOIN FETCH p.token t " +
       "JOIN FETCH t.meal m " +
       "JOIN FETCH p.seller s " +
       "JOIN FETCH s.hall " +
       "WHERE p.status = :status AND s.hall.id = :hallId " +
       "ORDER BY p.createdAt DESC")
List<MarketplacePost> findByStatusAndHallId(
    @Param("status") MarketplacePostStatus status,
    @Param("hallId") Long hallId
);
```

**JPQL vs SQL**:

| JPQL | SQL equivalent |
|------|---------------|
| `MarketplacePost p` | `marketplace_posts p` |
| `p.token` | `p.token_id` (follows the @ManyToOne join) |
| `p.seller.hall.id` | `users.hall_id` (navigates through relationships) |
| `JOIN FETCH p.token` | `JOIN tokens ON p.token_id = tokens.id` (eager load) |

**`JOIN FETCH`**: Tells Hibernate to load the related entity IN THE SAME QUERY (one SQL statement). Without it, Hibernate would make separate queries for each relationship = N+1 problem (very slow).

### 13.5 — How Spring generates the implementation

You write:
```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

At startup, Spring:
1. Sees the interface extends `JpaRepository`
2. Creates a **proxy class** (invisible to you) that implements the interface
3. For `findByEmail`: parses the name → generates the SQL → wraps in a method
4. Creates a bean of this proxy class and puts it in the container
5. When you inject `UserRepository`, you get this proxy

You NEVER write `class UserRepositoryImpl implements UserRepository` — Spring does it for you.

---

## Chapter 14: Services — Where Business Logic Lives

### 14.1 — What is a service?

A service class contains **business logic** — the rules of your application. It sits between the controller (HTTP layer) and the repository (database layer).

```
HTTP Request → Controller → Service → Repository → Database
HTTP Response ← Controller ← Service ← Repository ← Database
```

### 14.2 — Basic service structure

```java
@Service                           // Tell Spring: "this is a service, create a bean"
@RequiredArgsConstructor           // Lombok generates constructor for final fields
@Slf4j                             // Lombok creates: private static final Logger log = ...
public class MarketplaceService {

    // Dependencies (injected by Spring via constructor)
    private final MarketplaceRepository marketplaceRepository;
    private final TokenRepository tokenRepository;
    private final UserRepository userRepository;

    // Business method
    @Transactional
    public MarketplacePostResponse createSellPost(Long sellerId, Long tokenId) {
        // 1. Load data
        User seller = findUserOrThrow(sellerId);
        Token token = findTokenOrThrow(tokenId);

        // 2. Validate business rules
        if (!token.getOwner().getId().equals(sellerId)) {
            throw new MarketplaceException("You do not own this token");
        }

        // 3. Execute business logic
        token.setStatus(TokenStatus.LISTED);
        tokenRepository.save(token);

        // 4. Return result
        MarketplacePost post = MarketplacePost.builder()...build();
        post = marketplaceRepository.save(post);
        return toResponse(post);
    }
}
```

### 14.3 — `@Transactional` — the safety net

```java
@Transactional
public MarketplacePostResponse confirmTransfer(Long postId, Long sellerId) {
    // Step 1: Change token owner
    token.setOwner(buyer);
    tokenRepository.save(token);         // Database write #1

    // Step 2: Complete the post
    post.setStatus(MarketplacePostStatus.COMPLETED);
    marketplaceRepository.save(post);    // Database write #2

    // Step 3: Create transaction record
    tokenTransactionRepository.save(transaction);  // Database write #3
}
```

**What `@Transactional` does**: Wraps ALL three database writes in a single transaction. If Step 3 fails (exception), Steps 1 and 2 are **automatically rolled back**. Either ALL succeed, or NONE succeed.

**Without `@Transactional`**: If Step 3 fails, Steps 1 and 2 are already committed. The token changed owner but no transaction record exists = data corruption.

| Annotation | Behavior |
|-----------|----------|
| `@Transactional` | Read-write transaction, rolls back on any RuntimeException |
| `@Transactional(readOnly = true)` | Read-only optimization, no write locks on the database |

### 14.4 — Logging with `@Slf4j`

```java
@Slf4j  // Lombok creates: private static final Logger log = LoggerFactory.getLogger(...)
public class MarketplaceService {

    public void someMethod() {
        log.info("Token {} listed for sale by user {}", tokenId, sellerId);
        log.warn("Marketplace error: {}", ex.getMessage());
        log.error("Unexpected error: ", ex);  // prints stack trace
        log.debug("Debug info: {}", value);   // only shows when log level is DEBUG
    }
}
```

The `{}` are placeholders that get filled with the arguments. It's more efficient than string concatenation because the string is only built if the log level is enabled.

---

## Chapter 15: Controllers — Handling HTTP Requests

### 15.1 — What is a controller?

A controller receives HTTP requests from the frontend (or any client), calls the appropriate service method, and returns the response as JSON.

### 15.2 — Basic controller structure

```java
@RestController                                    // "I handle HTTP requests and return JSON"
@RequestMapping("/api/v1/marketplace")             // "All my endpoints start with this path"
@RequiredArgsConstructor                           // DI via constructor
public class MarketplaceController {

    private final MarketplaceService service;      // Injected by Spring
    private final UserRepository userRepository;   // Injected by Spring

    // GET endpoint
    @GetMapping
    public ApiResponse<List<MarketplacePostResponse>> browseMarketplace(
            @RequestHeader("X-User-Id") String userIdHeader) {

        Long userId = Long.parseLong(userIdHeader);
        User user = userRepository.findById(userId).orElseThrow(...);
        Long hallId = user.getHall().getId();

        List<MarketplacePostResponse> posts = service.getOpenPosts(hallId);
        return ApiResponse.success(posts, "Listings fetched");
    }

    // POST endpoint
    @PostMapping("/sell")
    public ApiResponse<MarketplacePostResponse> sellToken(
            @RequestHeader("X-User-Id") String userIdHeader,
            @RequestBody SellRequest request) {

        Long userId = Long.parseLong(userIdHeader);
        return ApiResponse.success(
            service.createSellPost(userId, request.getTokenId()),
            "Token listed for sale"
        );
    }
}
```

### 15.3 — HTTP method annotations

| Annotation | HTTP Method | Typical use |
|-----------|-------------|-------------|
| `@GetMapping` | GET | Fetch data |
| `@PostMapping` | POST | Create/perform action |
| `@PutMapping` | PUT | Update (replace) |
| `@PatchMapping` | PATCH | Update (partial) |
| `@DeleteMapping` | DELETE | Remove |

### 15.4 — Parameter annotations

#### `@RequestHeader` — Read from HTTP headers
```java
@GetMapping
public void example(@RequestHeader("X-User-Id") String userId) {
    // Reads the X-User-Id header from the HTTP request
}
```

The request must include the header:
```
GET /api/v1/marketplace HTTP/1.1
X-User-Id: 3
```

#### `@RequestBody` — Read from request body (JSON)
```java
@PostMapping("/sell")
public void example(@RequestBody SellRequest request) {
    // Spring automatically converts JSON body → SellRequest object
    Long tokenId = request.getTokenId();
}
```

The request body:
```json
{
    "tokenId": 5
}
```

Spring (via Jackson library) automatically converts this JSON into a `SellRequest` object: `request.getTokenId()` → `5`.

#### `@PathVariable` — Read from URL path
```java
@PostMapping("/{id}/buy-request")
public void example(@PathVariable Long id) {
    // POST /api/v1/marketplace/42/buy-request → id = 42
}
```

### 15.5 — How JSON response works

`@RestController` automatically converts your return value to JSON using the Jackson library.

**Your method returns:**
```java
return ApiResponse.success(post, "Token listed for sale");
```

**Spring converts to JSON:**
```json
{
    "success": true,
    "message": "Token listed for sale",
    "data": {
        "id": 1,
        "tokenId": 5,
        "mealType": "LUNCH",
        "mealDate": "2026-03-01",
        "sellerId": 1,
        "sellerName": "Rumi Ahmed",
        "status": "OPEN"
    }
}
```

Jackson converts Java objects to JSON by:
1. Looking at all getter methods (`getId()`, `getTokenId()`, etc.)
2. Converting each to a JSON key (`id`, `tokenId`, etc.)
3. Converting values to JSON types (`Long → number`, `String → string`, `null → null`)

---

## Chapter 16: How Frontend Connects to Backend

### 16.1 — The big picture

```
┌──────────────────┐         HTTP Request          ┌──────────────────┐
│                  │  ──────────────────────────▶  │                  │
│  Flutter App     │    POST /api/v1/marketplace/  │  Spring Boot     │
│  (Frontend)      │    sell                       │  (Backend)       │
│                  │    Header: X-User-Id: 1       │                  │
│  Port: varies    │    Body: {"tokenId": 5}       │  Port: 8080      │
│                  │                               │                  │
│                  │  ◀──────────────────────────  │                  │
│                  │         HTTP Response          │                  │
│                  │    200 OK                      │                  │
│                  │    {"success":true,...}         │                  │
└──────────────────┘                               └──────────────────┘
```

### 16.2 — What happens step by step

**Flutter sends a request:**
```dart
// In api_service.dart
static Future<MarketplacePostModel> sellToken(int userId, int tokenId) async {
    final res = await http.post(
        Uri.parse('http://localhost:8080/api/v1/marketplace/sell'),  // 1. URL
        headers: {
            'Content-Type': 'application/json',   // 2. Tell server: body is JSON
            'X-User-Id': userId.toString(),       // 3. Custom auth header
        },
        body: jsonEncode({'tokenId': tokenId}),   // 4. Body: {"tokenId": 5}
    );
    final body = jsonDecode(res.body);            // 5. Parse JSON response
    return MarketplacePostModel.fromJson(body['data']); // 6. Convert to Dart model
}
```

**Spring Boot receives and processes:**
```
Step 1: Tomcat (embedded server) receives the HTTP request on port 8080

Step 2: Spring's DispatcherServlet routes the request:
        POST + /api/v1/marketplace/sell → MarketplaceController.sellToken()

Step 3: Spring reads annotations on the method:
        @RequestHeader("X-User-Id") → extracts "1" from headers → passes as parameter
        @RequestBody SellRequest → deserializes {"tokenId": 5} → SellRequest object

Step 4: Controller method runs:
        → calls service.createSellPost(1, 5)
        → service validates + creates post + returns DTO

Step 5: Controller returns ApiResponse.success(post, "Token listed for sale")

Step 6: Jackson serializes the ApiResponse to JSON

Step 7: Tomcat sends HTTP 200 response with JSON body back to Flutter
```

**Flutter receives the response:**
```
Step 8: http.post() returns the response
Step 9: jsonDecode() converts JSON string → Dart Map
Step 10: MarketplacePostModel.fromJson() converts Map → Dart object
Step 11: UI rebuilds with the new data
```

### 16.3 — File-to-file connection map

```
FLUTTER                              SPRING BOOT
──────────────────                    ──────────────────
api_service.dart                      
  ↓ HTTP POST                        
  sellToken()        ──────────▶     MarketplaceController.java
                                       sellToken()
                                       ↓ calls
                                     MarketplaceService.java
                                       createSellPost()
                                       ↓ calls
                                     MarketplaceRepository.java
                                       save()
                                       ↓ SQL
                                     PostgreSQL Database
                                       INSERT INTO marketplace_posts ...
                                       ↓ returns entity
                                     MarketplaceService.java
                                       toResponse() → DTO
                                       ↓ returns DTO
                                     MarketplaceController.java
                                       ApiResponse.success(dto)
  ◀──────────────────────────────       ↓ JSON response

models.dart
  MarketplacePostModel.fromJson()
  ↓
marketplace_screen.dart
  setState() → UI updates
```

### 16.4 — CORS — Why the frontend can even talk to the backend

Browsers block cross-origin requests by default (security). Your Flutter web app runs on port 5000 (or similar), but the backend is on port 8080. This is a CORS issue.

Your `CorsConfig.java` fixes it:

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")     // For all /api/... endpoints
                .allowedOrigins("*")       // Allow ANY origin (domain/port)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");      // Allow any headers (including X-User-Id)
    }
}
```

### 16.5 — The full data flow diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│                                                                 │
│  ┌──────────────┐   ┌──────────────┐   ┌───────────────────┐   │
│  │ marketplace_  │──▶│ api_service. │──▶│  HTTP Request     │   │
│  │ screen.dart   │   │ dart         │   │  (over network)   │──┐│
│  └──────────────┘   └──────────────┘   └───────────────────┘  ││
│         ▲                                                      ││
│         │                                                      ││
│  ┌──────────────┐   ┌──────────────┐   ┌───────────────────┐  ││
│  │ setState()   │◀──│ fromJson()   │◀──│  HTTP Response    │◀┐││
│  │ rebuilds UI  │   │ models.dart  │   │  (JSON)           │ │││
│  └──────────────┘   └──────────────┘   └───────────────────┘ │││
└──────────────────────────────────────────────────────────────│─┘│
                                                               │  │
                          ┌────NETWORK────┐                    │  │
                                                               │  │
┌──────────────────────────────────────────────────────────────│──┘
│                      SPRING BOOT APP                         │
│                                                              │
│  ┌──────────────────┐                                        │
│  │ Tomcat (port 8080)│◀───────── receives request ───────────┘
│  └────────┬─────────┘
│           │ routes to
│  ┌────────▼──────────┐
│  │  Controller       │  reads headers, body, path params
│  │  (@RestController) │
│  └────────┬──────────┘
│           │ calls
│  ┌────────▼──────────┐
│  │  Service          │  validates, processes business logic
│  │  (@Service)       │  @Transactional ensures atomicity
│  └────────┬──────────┘
│           │ calls
│  ┌────────▼──────────┐
│  │  Repository       │  generates SQL, executes queries
│  │  (JpaRepository)  │
│  └────────┬──────────┘
│           │ SQL
│  ┌────────▼──────────┐
│  │  PostgreSQL DB    │  stores/retrieves data
│  └───────────────────┘
│
└──────────────────────────────────────────────────────────────────┘
```

---

## Chapter 16.5: Spring Boot Syntax — Complete Reference

This chapter covers the **exact syntax patterns** you'll write over and over in Spring Boot. Think of it as a "how to write things" reference.

---

### S1 — File structure syntax

Every Java file has this structure:

```java
package dsi.ruet.backend.marketplace;   // 1. Package declaration (MUST match folder path)

import java.util.List;                   // 2. Imports (libraries you use)
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service                                 // 3. Class-level annotation(s)
@RequiredArgsConstructor
public class MarketplaceService {        // 4. Class declaration

    private final TokenRepository repo;  // 5. Fields

    public void doSomething() {          // 6. Methods
        // logic here
    }
}
```

**Rules:**
- Package declaration is ALWAYS the first line (after comments)
- Imports come AFTER the package declaration
- One public class per file
- Filename MUST match the class name: `MarketplaceService.java` → `class MarketplaceService`
- Package path MUST match folder path: `dsi.ruet.backend.marketplace` → `dsi/ruet/backend/marketplace/`

---

### S2 — How to declare an Entity (database table)

**Template:**

```java
package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity                             // Required: marks this as a DB table
@Table(name = "table_name")         // Optional: set table name (defaults to class name)
@Data                               // Lombok: getters, setters, toString, equals, hashCode
@NoArgsConstructor                  // Lombok: empty constructor
@AllArgsConstructor                 // Lombok: all-fields constructor
@Builder                            // Lombok: builder pattern
public class MyEntity {

    @Id                                                     // Primary key
    @GeneratedValue(strategy = GenerationType.IDENTITY)     // Auto-increment
    private Long id;

    @Column(nullable = false)                               // NOT NULL
    private String name;

    @Column(unique = true)                                  // UNIQUE constraint
    private String email;

    @Column(columnDefinition = "TEXT")                       // Long text
    private String description;

    @Column(name = "custom_column_name")                    // Custom column name
    private String javaField;

    @Enumerated(EnumType.STRING)                            // Store enum as text
    @Column(nullable = false)
    private MyEnum status;

    private LocalDateTime createdAt;                        // No @Column = defaults

    // --- Relationships ---

    @ManyToOne(fetch = FetchType.LAZY)                      // FK to another table
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToOne(fetch = FetchType.LAZY)                       // 1:1 shared PK
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    // --- Lifecycle hooks ---

    @PrePersist                                             // Runs before first INSERT
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
```

**Unique constraint on multiple columns:**

```java
@Table(name = "tokens", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"owner_id", "meal_id"})
})
public class Token { ... }
```

---

### S3 — How to declare an Enum

```java
package dsi.ruet.backend.models.enums;

public enum TokenStatus {
    AVAILABLE,
    IN_QUEUE,
    USED,
    LISTED
}
```

**That's it.** No annotations, no imports. Just list the values separated by commas.

**Using an enum:**
```java
token.setStatus(TokenStatus.AVAILABLE);            // Set value
if (token.getStatus() == TokenStatus.LISTED) { }   // Compare with ==
String name = TokenStatus.AVAILABLE.name();         // → "AVAILABLE"
```

---

### S4 — How to declare a Repository

**Template (simplest form):**

```java
package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    //              ↑ must be "interface", NOT "class"        ↑      ↑
    //                                                    Entity  PK type
}
```

**With derived queries (Spring generates SQL from method name):**

```java
public interface UserRepository extends JpaRepository<User, Long> {

    // Pattern: findBy + FieldName + (And/Or + FieldName)*
    Optional<User> findByEmail(String email);
    List<User> findByHallId(Long hallId);
    List<User> findByRoleAndHallId(Role role, Long hallId);
    boolean existsByEmail(String email);
    long countByHallId(Long hallId);
    List<User> findByNameContaining(String keyword);         // LIKE '%keyword%'
    List<User> findByCreatedAtAfter(LocalDateTime date);     // WHERE created_at > ?
    Optional<User> findFirstByHallIdOrderByNameAsc(Long id); // LIMIT 1
}
```

**With custom JPQL queries:**

```java
public interface MarketplaceRepository extends JpaRepository<MarketplacePost, Long> {

    @Query("SELECT p FROM MarketplacePost p " +              // SELECT from entity name
           "JOIN FETCH p.token t " +                         // Eager-load relationship
           "JOIN FETCH t.meal m " +                          // Chain relationships
           "WHERE p.status = :status " +                     // Named parameter
           "AND p.seller.hall.id = :hallId " +               // Navigate nested relations
           "ORDER BY p.createdAt DESC")                      // Sort
    List<MarketplacePost> findByStatusAndHallId(
        @Param("status") MarketplacePostStatus status,       // Bind :status
        @Param("hallId") Long hallId                         // Bind :hallId
    );

    // Update query (modifies data instead of selecting)
    @Modifying                                               // Required for UPDATE/DELETE
    @Query("UPDATE Token t SET t.status = :status WHERE t.id = :id")
    void updateStatus(@Param("id") Long id, @Param("status") TokenStatus status);
}
```

**JPQL syntax rules:**
- Use **Java class names** (`MarketplacePost`), not SQL table names (`marketplace_posts`)
- Use **Java field names** (`p.createdAt`), not column names (`created_at`)
- Navigate relationships with dots: `p.seller.hall.id` = "post → seller → hall → id"
- `:paramName` for named parameters, bound with `@Param("paramName")`

---

### S5 — How to declare a Service

**Template:**

```java
package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.models.*;
import dsi.ruet.backend.repositories.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service                       // Registers as a Spring bean
@RequiredArgsConstructor       // Constructor injection (for final fields)
@Slf4j                         // Creates: log.info(), log.warn(), log.error()
public class MarketplaceService {

    // Dependencies — Spring injects these automatically
    private final MarketplaceRepository marketplaceRepository;
    private final TokenRepository tokenRepository;
    private final UserRepository userRepository;

    // --- Read operation (no @Transactional needed, or use readOnly) ---
    public List<PostResponse> getAllPosts() {
        return marketplaceRepository.findAll()
                .stream()
                .map(this::toResponse)          // convert each entity to DTO
                .collect(Collectors.toList());
    }

    // --- Write operation (use @Transactional for safety) ---
    @Transactional
    public PostResponse createPost(Long userId, Long tokenId) {
        // 1. Load entities
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        Token token = tokenRepository.findById(tokenId)
                .orElseThrow(() -> new RuntimeException("Token not found: " + tokenId));

        // 2. Validate business rules
        if (!token.getOwner().getId().equals(userId)) {
            throw new RuntimeException("You don't own this token");
        }

        // 3. Modify and save
        token.setStatus(TokenStatus.LISTED);
        tokenRepository.save(token);

        MarketplacePost post = MarketplacePost.builder()
                .token(token)
                .seller(user)
                .status(MarketplacePostStatus.OPEN)
                .build();
        post = marketplaceRepository.save(post);

        // 4. Log and return
        log.info("Token {} listed for sale by user {}", tokenId, userId);
        return toResponse(post);
    }

    // --- Private helper (not accessible from outside) ---
    private PostResponse toResponse(MarketplacePost post) {
        return PostResponse.builder()
                .id(post.getId())
                .tokenId(post.getToken().getId())
                .sellerName(post.getSeller().getName())
                .build();
    }
}
```

---

### S6 — How to declare a Controller

**Template:**

```java
package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController                                    // Handles HTTP, returns JSON
@RequestMapping("/api/v1/marketplace")             // Base URL path
@RequiredArgsConstructor                           // Constructor DI
public class MarketplaceController {

    private final MarketplaceService service;      // Injected


    // ===== GET — Fetch data =====
    // GET /api/v1/marketplace
    @GetMapping
    public ApiResponse<List<PostResponse>> getAll() {
        return ApiResponse.success(service.getAllPosts(), "Fetched");
    }

    // GET /api/v1/marketplace/5
    @GetMapping("/{id}")
    public ApiResponse<PostResponse> getById(@PathVariable Long id) {
        return ApiResponse.success(service.getById(id), "Fetched");
    }


    // ===== POST — Create / perform action =====
    // POST /api/v1/marketplace/sell
    @PostMapping("/sell")
    public ApiResponse<PostResponse> sell(
            @RequestHeader("X-User-Id") String userIdHeader,   // From HTTP header
            @RequestBody SellRequest request) {                // From JSON body

        Long userId = Long.parseLong(userIdHeader);
        return ApiResponse.success(
            service.createPost(userId, request.getTokenId()),
            "Created"
        );
    }


    // ===== PUT — Update (replace) =====
    // PUT /api/v1/marketplace/5
    @PutMapping("/{id}")
    public ApiResponse<PostResponse> update(
            @PathVariable Long id,                              // From URL path
            @RequestBody UpdateRequest request) {               // From JSON body
        return ApiResponse.success(service.update(id, request), "Updated");
    }


    // ===== DELETE — Remove =====
    // DELETE /api/v1/marketplace/5
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ApiResponse.success(null, "Deleted");
    }


    // ===== With query parameters =====
    // GET /api/v1/marketplace/search?status=OPEN&hallId=1
    @GetMapping("/search")
    public ApiResponse<List<PostResponse>> search(
            @RequestParam MarketplacePostStatus status,         // ?status=OPEN
            @RequestParam Long hallId) {                        // ?hallId=1
        return ApiResponse.success(service.search(status, hallId), "Fetched");
    }


    // ===== With optional query parameters =====
    // GET /api/v1/marketplace/filter?page=0&size=10  (or just /filter)
    @GetMapping("/filter")
    public ApiResponse<List<PostResponse>> filter(
            @RequestParam(defaultValue = "0") int page,           // defaults to 0
            @RequestParam(defaultValue = "10") int size,          // defaults to 10
            @RequestParam(required = false) String keyword) {     // nullable
        return ApiResponse.success(service.filter(page, size, keyword), "Fetched");
    }
}
```

**All parameter annotation types:**

```java
// From URL path:          /api/items/42
@PathVariable Long id                                    // id = 42

// From query string:      /api/items?status=OPEN
@RequestParam String status                              // status = "OPEN"

// From query (optional):  /api/items  (no param = default)
@RequestParam(defaultValue = "0") int page               // page = 0
@RequestParam(required = false) String keyword           // keyword = null

// From HTTP header:       X-User-Id: 3
@RequestHeader("X-User-Id") String userId                // userId = "3"

// From JSON body:         {"tokenId": 5, "price": 60}
@RequestBody SellRequest request                         // request.getTokenId() = 5

// Multiple path vars:     /api/halls/1/meals/3
@GetMapping("/halls/{hallId}/meals/{mealId}")
public void get(@PathVariable Long hallId, @PathVariable Long mealId) { }
```

---

### S7 — How to declare a DTO (Data Transfer Object)

DTOs are simple data-carrier classes used for API input/output. They separate your API shape from your database shape.

**Input DTO (what the client sends):**

```java
package dsi.ruet.backend.marketplace.dto;

import lombok.Data;

@Data                          // Getters + setters (Jackson needs setters for input)
public class SellRequest {
    private Long tokenId;      // Matches JSON key: { "tokenId": 5 }
}
```

**Output DTO (what the API returns):**

```java
package dsi.ruet.backend.marketplace.dto;

import lombok.*;

@Data
@Builder                       // So the service can build it: PostResponse.builder()...
@NoArgsConstructor
@AllArgsConstructor
public class MarketplacePostResponse {
    private Long id;
    private Long tokenId;
    private String mealType;
    private String sellerName;
    private String status;
}
```

**Generic API response wrapper:**

```java
package dsi.ruet.backend.common.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {                // <T> = generic type (can hold any data)
    private boolean success;
    private String message;
    private T data;                          // T = whatever type you pass

    // Static factory method for success
    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .build();
    }

    // Static factory method for error
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .data(null)
                .build();
    }
}
```

**How generics `<T>` work:**

```java
ApiResponse<User>                → data is of type User
ApiResponse<List<PostResponse>>  → data is of type List<PostResponse>
ApiResponse<Void>                → data is null (no data)

// Usage:
return ApiResponse.success(postResponse, "Created");
// T is inferred as MarketplacePostResponse at compile time
```

---

### S8 — How to declare a Custom Exception

```java
package dsi.ruet.backend.marketplace.exception;

public class MarketplaceException extends RuntimeException {
    public MarketplaceException(String message) {
        super(message);     // Pass message to parent RuntimeException
    }
}
```

**Throwing it:**
```java
throw new MarketplaceException("You do not own this token");
```

---

### S9 — How to declare a Global Exception Handler

```java
package dsi.ruet.backend.common.exception;

import dsi.ruet.backend.common.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestControllerAdvice                              // Catches exceptions from ALL controllers
public class GlobalExceptionHandler {

    // Catch MarketplaceException → 400 Bad Request
    @ExceptionHandler(MarketplaceException.class)
    public ResponseEntity<ApiResponse<Void>> handleMarketplace(MarketplaceException ex) {
        return ResponseEntity
                .badRequest()                      // HTTP 400
                .body(ApiResponse.error(ex.getMessage()));
    }

    // Catch everything else → 500 Internal Server Error
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGeneral(Exception ex) {
        return ResponseEntity
                .internalServerError()             // HTTP 500
                .body(ApiResponse.error("Something went wrong"));
    }
}
```

**`ResponseEntity` syntax:**
```java
ResponseEntity.ok(body)                            // 200 OK
ResponseEntity.badRequest().body(body)              // 400 Bad Request
ResponseEntity.status(HttpStatus.NOT_FOUND).body(b) // 404 Not Found
ResponseEntity.internalServerError().body(body)     // 500 Internal Error
ResponseEntity.status(201).body(body)               // 201 Created
ResponseEntity.noContent().build()                  // 204 No Content (no body)
```

---

### S10 — How to declare a Configuration class

```java
package dsi.ruet.backend.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration                                 // "This class provides configuration"
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")         // All /api/... URLs
                .allowedOrigins("*")           // From any domain
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
```

**Defining custom beans in a config class:**

```java
@Configuration
public class AppConfig {

    @Bean                                      // Spring manages the returned object
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }

    // You can inject this anywhere:
    // private final ObjectMapper objectMapper;
}
```

---

### S11 — How to declare a Scheduled task

```java
package dsi.ruet.backend.marketplace;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component                                     // Register as a bean
@RequiredArgsConstructor
public class MarketplaceScheduler {

    private final MarketplaceService service;

    @Scheduled(fixedRate = 60000)              // Every 60 seconds (in milliseconds)
    public void checkTimeouts() {
        service.expireTimedOutRequests();
    }

    // Other scheduling options:
    @Scheduled(fixedDelay = 30000)             // 30s AFTER the previous run finishes
    @Scheduled(initialDelay = 5000, fixedRate = 60000)  // Wait 5s, then every 60s
    @Scheduled(cron = "0 0 * * * *")           // Every hour (cron expression)
}
```

**Requires `@EnableScheduling` on the main application class!**

---

### S12 — How to declare a Data Seeder (run code on startup)

```java
package dsi.ruet.backend.seeder;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component                                          // Register as a bean
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final HallRepository hallRepository;
    private final UserRepository userRepository;

    @Override
    public void run(String... args) {               // Runs once after app starts
        if (hallRepository.count() > 0) return;     // Skip if data already exists

        Hall hall = Hall.builder()
                .name("Shaheed Abdur Rab Hall")
                .build();
        hall = hallRepository.save(hall);            // save() returns entity with ID

        userRepository.save(User.builder()
                .name("Rumi Ahmed")
                .email("rumi@student.ruet.ac.bd")
                .password("password")
                .hall(hall)
                .role(Role.STUDENT)
                .build());
    }
}
```

---

### S13 — Common Java syntax patterns used in Spring Boot

**Ternary operator (inline if):**
```java
String status = (age >= 18) ? "adult" : "minor";
// same as: if (age >= 18) status = "adult"; else status = "minor";
```

**Null-safe checks:**
```java
if (buyer != null) { ... }                // simple null check

// Optional usage (from repository .findById)
User user = userRepository.findById(id)
    .orElseThrow(() -> new RuntimeException("Not found"));

// Null-safe with Optional
Optional<User> maybe = userRepository.findById(id);
maybe.ifPresent(user -> System.out.println(user.getName()));
String name = maybe.map(User::getName).orElse("Unknown");
```

**String formatting:**
```java
// Concatenation
"User not found: " + userId

// String.format
String.format("User %d not found in hall %s", userId, hallName)

// Log placeholders (most common in Spring Boot)
log.info("Token {} listed by user {}", tokenId, userId);
```

**Stream operations (most commonly used):**
```java
// Convert List<A> → List<B>
List<PostResponse> responses = posts.stream()
    .map(this::toResponse)
    .collect(Collectors.toList());

// Filter a list
List<Token> availableTokens = tokens.stream()
    .filter(t -> t.getStatus() == TokenStatus.AVAILABLE)
    .collect(Collectors.toList());

// Find first match
Optional<Token> found = tokens.stream()
    .filter(t -> t.getId().equals(targetId))
    .findFirst();

// Check if any match
boolean hasListed = tokens.stream()
    .anyMatch(t -> t.getStatus() == TokenStatus.LISTED);

// Count matches
long count = tokens.stream()
    .filter(t -> t.getStatus() == TokenStatus.USED)
    .count();
```

**Method references (shorthand for lambdas):**
```java
// These are the same:
.map(post -> toResponse(post))     // lambda
.map(this::toResponse)             // method reference

// These are the same:
.map(user -> user.getName())       // lambda
.map(User::getName)                // method reference
```

**Exception handling (try-catch):**
```java
try {
    Long userId = Long.parseLong(userIdHeader);     // might fail if not a number
} catch (NumberFormatException e) {
    throw new RuntimeException("Invalid user ID: " + userIdHeader);
}
```

**Type casting:**
```java
Object obj = getResult();
if (obj instanceof String) {
    String str = (String) obj;      // cast Object → String
}

// Modern pattern matching (Java 16+)
if (obj instanceof String str) {
    // str is already cast
}
```

---

### S14 — Import statements — What to import for what

| When you use... | Import this |
|----------------|-------------|
| `@Entity`, `@Table`, `@Id`, `@Column`, `@ManyToOne` | `import jakarta.persistence.*;` |
| `@Service`, `@Component`, `@Repository` | `import org.springframework.stereotype.*;` |
| `@RestController`, `@GetMapping`, `@RequestBody` | `import org.springframework.web.bind.annotation.*;` |
| `@Transactional` | `import org.springframework.transaction.annotation.Transactional;` |
| `@Scheduled` | `import org.springframework.scheduling.annotation.Scheduled;` |
| `JpaRepository`, `@Query`, `@Param` | `import org.springframework.data.jpa.repository.*;` |
| `CommandLineRunner` | `import org.springframework.boot.CommandLineRunner;` |
| `@Configuration` | `import org.springframework.context.annotation.Configuration;` |
| `@Bean` | `import org.springframework.context.annotation.Bean;` |
| `ResponseEntity` | `import org.springframework.http.ResponseEntity;` |
| `@Data`, `@Builder`, etc. | `import lombok.*;` |
| `@Slf4j` | `import lombok.extern.slf4j.Slf4j;` |
| `List`, `Optional`, `Map` | `import java.util.*;` |
| `Collectors` | `import java.util.stream.Collectors;` |
| `LocalDate`, `LocalDateTime` | `import java.time.*;` |

**Pro tip**: Use `.*` (wildcard) to import everything from a package when you use multiple things from it:
```java
import jakarta.persistence.*;                        // Instead of 6 separate imports
import org.springframework.web.bind.annotation.*;    // Instead of 8 separate imports
```

---

### S15 — Complete syntax for building a new feature from scratch

Here's the **exact order** and **exact syntax** to create a new feature (e.g., "Wallet top-up"):

**Step 1 — Entity** (`models/TopUpRequest.java`):
```java
package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "topup_requests")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class TopUpRequest {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private Double amount;

    @Column(nullable = false)
    private String transactionRef;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
```

**Step 2 — Repository** (`repositories/TopUpRequestRepository.java`):
```java
package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.TopUpRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TopUpRequestRepository extends JpaRepository<TopUpRequest, Long> {
    List<TopUpRequest> findByUserIdOrderByCreatedAtDesc(Long userId);
}
```

**Step 3 — DTO** (`wallet/dto/TopUpDto.java`):
```java
package dsi.ruet.backend.wallet.dto;

import lombok.Data;

@Data
public class TopUpDto {
    private Double amount;
    private String transactionRef;
}
```

**Step 4 — Exception** (`wallet/exception/WalletException.java`):
```java
package dsi.ruet.backend.wallet.exception;

public class WalletException extends RuntimeException {
    public WalletException(String message) { super(message); }
}
```

**Step 5 — Service** (`wallet/WalletService.java`):
```java
package dsi.ruet.backend.wallet;

import dsi.ruet.backend.models.*;
import dsi.ruet.backend.repositories.*;
import dsi.ruet.backend.wallet.dto.TopUpDto;
import dsi.ruet.backend.wallet.exception.WalletException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class WalletService {

    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final TopUpRequestRepository topUpRequestRepository;

    @Transactional
    public Wallet topUp(Long userId, TopUpDto dto) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new WalletException("User not found"));

        Wallet wallet = walletRepository.findById(userId)
            .orElseThrow(() -> new WalletException("Wallet not found"));

        if (dto.getAmount() <= 0) {
            throw new WalletException("Amount must be positive");
        }

        wallet.credit(dto.getAmount());
        walletRepository.save(wallet);

        topUpRequestRepository.save(TopUpRequest.builder()
            .user(user)
            .amount(dto.getAmount())
            .transactionRef(dto.getTransactionRef())
            .build());

        log.info("Wallet topped up: userId={}, amount={}", userId, dto.getAmount());
        return wallet;
    }
}
```

**Step 6 — Controller** (`wallet/WalletController.java`):
```java
package dsi.ruet.backend.wallet;

import dsi.ruet.backend.common.dto.ApiResponse;
import dsi.ruet.backend.models.Wallet;
import dsi.ruet.backend.wallet.dto.TopUpDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @PostMapping("/topup")
    public ApiResponse<Wallet> topUp(
            @RequestHeader("X-User-Id") String userIdHeader,
            @RequestBody TopUpDto dto) {
        Long userId = Long.parseLong(userIdHeader);
        return ApiResponse.success(walletService.topUp(userId, dto), "Top-up successful");
    }
}
```

**Step 7 — Register exception** (add to `GlobalExceptionHandler.java`):
```java
@ExceptionHandler(WalletException.class)
public ResponseEntity<ApiResponse<Void>> handleWallet(WalletException ex) {
    return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
}
```

**Done.** Start the server → `POST /api/v1/wallet/topup` works.

---

# PART 3: YOUR PROJECT EXPLAINED

---

## Chapter 17: `application.properties` — The Configuration Hub

```properties
# App name (shows in logs)
spring.application.name=backend

# Database connection string
spring.datasource.url=jdbc:postgresql://localhost:5432/dsiApp
#                      ^^^^ ^^^^^^^^^^  ^^^^^^^^^  ^^^^ ^^^^^^
#                      Java DB type     hostname   port  DB name
#                      Database
#                      Connectivity

# Database credentials
spring.datasource.username=aliazgorrumi
spring.datasource.password=

# Table auto-creation strategy
spring.jpa.hibernate.ddl-auto=update

# Tell Hibernate we're using PostgreSQL
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# Show SQL in console (for debugging)
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Show detailed app logs
logging.level.dsi.ruet.backend=DEBUG
```

**JDBC URL breakdown**:
```
jdbc:postgresql://localhost:5432/dsiApp
│    │            │         │    │
│    │            │         │    └── database name
│    │            │         └── port number
│    │            └── hostname (your machine)
│    └── which database type
└── Java Database Connectivity protocol
```

**How Spring Boot reads this**: At startup, Spring automatically reads `application.properties` from `src/main/resources/`. It creates a `DataSource` bean (database connection pool) using these settings. Hibernate uses the `DataSource` to connect and the `ddl-auto` setting to manage tables.

---

## Chapter 18: `BackendApplication.java` — The Entry Point

```java
package dsi.ruet.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication      // = @Configuration + @EnableAutoConfiguration + @ComponentScan
@EnableScheduling            // Enables @Scheduled methods (marketplace timeout scheduler)
public class BackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}
```

**`@SpringBootApplication` is actually THREE annotations combined:**

| Hidden annotation | What it does |
|------------------|-------------|
| `@Configuration` | This class can define beans |
| `@EnableAutoConfiguration` | Spring Boot automatically configures everything based on your dependencies (sees `postgresql` → configures DB, sees `webmvc` → configures Tomcat, etc.) |
| `@ComponentScan` | Scans `dsi.ruet.backend` and ALL sub-packages for `@Component`, `@Service`, `@Controller`, `@Repository` classes and creates beans |

**`@EnableScheduling`**: Without this, `@Scheduled` methods are ignored. This activates the scheduler that runs your marketplace timeout checker every 60 seconds.

**`SpringApplication.run()`**: This single line:
1. Creates the ApplicationContext (Spring container)
2. Registers all beans
3. Starts the embedded Tomcat server
4. Runs any `CommandLineRunner` beans (your `DataSeeder`)
5. Begins accepting HTTP requests

---

## Chapter 19: The Request Lifecycle — What Happens When Flutter Sends a Request

Let's trace a complete request from start to finish:

### Example: `POST /api/v1/marketplace/sell` with body `{"tokenId": 5}` and header `X-User-Id: 1`

```
STEP 1 — NETWORK
─────────────────
Flutter sends HTTP request over TCP to localhost:8080.

STEP 2 — TOMCAT
─────────────────
Embedded Tomcat web server receives the raw HTTP bytes.
Parses them into an HttpServletRequest object.

STEP 3 — DISPATCHER SERVLET
────────────────────────────
Spring's DispatcherServlet (the front controller) receives the request.
It checks: which @Controller method handles POST + /api/v1/marketplace/sell?
Finds: MarketplaceController.sellToken()

STEP 4 — ARGUMENT RESOLUTION
────────────────────────────
Spring looks at the method parameters:
  @RequestHeader("X-User-Id") String userIdHeader → extracts "1" from headers
  @RequestBody SellRequest request → reads JSON body, creates SellRequest(tokenId=5)

STEP 5 — CONTROLLER METHOD RUNS
────────────────────────────────
sellToken() method executes:
  Long userId = Long.parseLong("1") → 1L
  Calls: service.createSellPost(1L, 5L)

STEP 6 — SERVICE METHOD RUNS (inside @Transactional)
─────────────────────────────────────────────────────
Spring creates a database transaction (BEGIN TRANSACTION).
createSellPost():
  a. userRepository.findById(1L) → SQL: SELECT * FROM users WHERE id = 1
     → Returns User(id=1, name="Rumi Ahmed")
  b. tokenRepository.findById(5L) → SQL: SELECT * FROM tokens WHERE id = 5
     → Returns Token(id=5, owner_id=1, status=AVAILABLE)
  c. Validates: owner matches? status is AVAILABLE? no duplicate listing?
  d. token.setStatus(LISTED)
     tokenRepository.save(token) → SQL: UPDATE tokens SET status = 'LISTED' WHERE id = 5
  e. Creates MarketplacePost entity
     marketplaceRepository.save(post) → SQL: INSERT INTO marketplace_posts (...) VALUES (...)
  f. Converts to MarketplacePostResponse DTO
If ALL succeed → COMMIT TRANSACTION
If ANY throw exception → ROLLBACK TRANSACTION

STEP 7 — CONTROLLER RETURNS
────────────────────────────
Returns: ApiResponse.success(dto, "Token listed for sale")

STEP 8 — JSON SERIALIZATION
────────────────────────────
Jackson converts ApiResponse → JSON string:
{
  "success": true,
  "message": "Token listed for sale",
  "data": { "id": 1, "tokenId": 5, "status": "OPEN", ... }
}

STEP 9 — RESPONSE SENT
─────────────────────────
Tomcat wraps JSON in HTTP response with status 200 OK.
Sends back to Flutter over TCP.

STEP 10 — EXCEPTION HANDLING (if something went wrong)
──────────────────────────────────────────────────────
If any step threw an exception:
  MarketplaceException → GlobalExceptionHandler → 400 Bad Request
  Other exceptions → 500 Internal Server Error
The response is still valid JSON (ApiResponse.error("message"))
```

---

## Chapter 20: Your Project File Map — What Each File Does

### Models (Database tables)

| File | Table | Purpose | Relationships |
|------|-------|---------|---------------|
| `Hall.java` | `halls` | University residential halls | — |
| `User.java` | `users` | Students and staff | → belongs to 1 Hall |
| `Wallet.java` | `wallets` | Digital coin balance | ↔ 1:1 with User (shared PK) |
| `StudentInfo.java` | `student_infos` | Roll, room, phone | ↔ 1:1 with User (shared PK) |
| `Meal.java` | `meals` | A meal event (date + type) | → belongs to 1 Hall |
| `Token.java` | `tokens` | Proof of meal purchase | → belongs to 1 Meal, → owned by 1 User |
| `CoinTransaction.java` | `coin_transactions` | Wallet transaction log | → sender User, → receiver User |
| `TokenTransaction.java` | `token_transactions` | Token transfer log | → sender User, → receiver User, → Token |
| `MarketplacePost.java` | `marketplace_posts` | Marketplace listing | → Token, → seller User, → buyer User |

### Enums

| File | Values | Used by |
|------|--------|---------|
| `Role.java` | STUDENT, MEAL_MANAGER, DINING_MANAGER | User.role |
| `MealType.java` | LUNCH, DINNER | Meal.mealType |
| `TokenStatus.java` | AVAILABLE, IN_QUEUE, USED, LISTED | Token.status |
| `TransactionType.java` | TOPUP, TRANSACTION | CoinTransaction.type |
| `MarketplacePostStatus.java` | OPEN, PENDING, COMPLETED | MarketplacePost.status |

### Repositories

| File | For entity | Custom methods |
|------|-----------|----------------|
| `HallRepository.java` | Hall | (none — basic CRUD only) |
| `UserRepository.java` | User | `findByEmail()`, `existsByEmail()` |
| `WalletRepository.java` | Wallet | (none) |
| `MealRepository.java` | Meal | `findByHallIdAndMealDateAndMealType()` |
| `TokenRepository.java` | Token | `findByOwnerId()`, `findByOwnerIdAndStatus()`, `existsByOwnerIdAndMealId()` |
| `TokenTransactionRepository.java` | TokenTransaction | `findBySenderIdOrReceiverId()` |
| `MarketplaceRepository.java` | MarketplacePost | 6 custom JPQL queries |

### Marketplace module

| File | Layer | What it does |
|------|-------|-------------|
| `MarketplacePost.java` | Entity | JPA entity → `marketplace_posts` table |
| `MarketplaceRepository.java` | Data access | 6 JPQL queries for browsing, filtering, timeout |
| `MarketplaceService.java` | Business logic | 12 public methods — all validation + logic |
| `MarketplaceController.java` | HTTP layer | 9 REST endpoints, parses headers/body |
| `MarketplaceScheduler.java` | Background job | Runs every 60s, expires 15-min old requests |
| `dto/SellRequest.java` | Input DTO | `{ "tokenId": 5 }` |
| `dto/MarketplacePostResponse.java` | Output DTO | Flattened response for API |
| `exception/MarketplaceException.java` | Error | Custom exception for marketplace errors |

### Common utilities

| File | What it does |
|------|-------------|
| `dto/ApiResponse.java` | Generic response wrapper: `{ success, message, data }` |
| `dto/UserResponse.java` | DTO for user data in API responses |
| `dto/TokenResponse.java` | DTO for token data in API responses |
| `config/CorsConfig.java` | Allows cross-origin requests from Flutter |
| `exception/GlobalExceptionHandler.java` | Catches exceptions → returns proper JSON errors |
| `controller/TestHelperController.java` | Temp test endpoints for listing users/tokens |

### Other

| File | What it does |
|------|-------------|
| `BackendApplication.java` | Entry point — starts everything |
| `DataSeeder.java` | Seeds demo data on first startup |

---

## Chapter 21: How Internal Spring Boot Magic Works

### 21.1 — Auto-Configuration

When Spring Boot starts and sees `spring-boot-starter-data-jpa` in your pom.xml:

```
Spring Boot sees: spring-boot-starter-data-jpa
  → Checks: is there a DataSource configured in application.properties?
    → YES: url, username, password found
    → Auto-creates: HikariDataSource (connection pool with 10 connections)
  → Checks: is there a JPA vendor?
    → YES: Hibernate on classpath
    → Auto-creates: EntityManagerFactory (Hibernate session factory)
  → Checks: are there @Entity classes?
    → YES: scans and registers them with Hibernate
    → Auto-runs: ddl-auto=update → creates/updates tables
  → Checks: are there JpaRepository interfaces?
    → YES: generates proxy implementations for each
```

When Spring Boot sees `spring-boot-starter-webmvc`:

```
Spring Boot sees: spring-boot-starter-webmvc
  → Auto-creates: Embedded Tomcat on port 8080
  → Auto-creates: DispatcherServlet (routes HTTP requests)
  → Auto-creates: Jackson ObjectMapper (JSON serialization)
  → Scans for: @RestController classes
  → Maps: URL patterns → controller methods
```

### 21.2 — Bean lifecycle

```
1. INSTANTIATION
   Spring calls the constructor → creates the object

2. DEPENDENCY INJECTION
   Spring fills in all @Autowired / constructor dependencies

3. POST-CONSTRUCTION
   If the class has @PostConstruct, it runs now

4. READY
   Bean is in the container, ready to use

5. PRE-DESTRUCTION (on app shutdown)
   If the class has @PreDestroy, it runs now
```

### 21.3 — How `@Scheduled` works internally

```java
@Scheduled(fixedRate = 60000)
public void expirePendingRequests() { ... }
```

1. `@EnableScheduling` on `BackendApplication` activates the scheduler
2. Spring scans for all methods with `@Scheduled`
3. Creates a `ThreadPoolTaskScheduler` (background thread pool)
4. Every 60,000 ms, the scheduler submits `expirePendingRequests()` to the thread pool
5. The method runs on a background thread (not the main thread)

### 21.4 — How `CommandLineRunner` (DataSeeder) works

```java
@Component
public class DataSeeder implements CommandLineRunner {
    @Override
    public void run(String... args) {
        // This runs automatically after Spring Boot is fully started
    }
}
```

1. Spring creates the `DataSeeder` bean
2. After ALL beans are created and the server is ready
3. Spring looks for all `CommandLineRunner` beans
4. Calls `run()` on each one
5. Then the app continues normally (accepting HTTP requests)

---

## Chapter 22: What's Next — Growing the Project

Now that you understand the foundation, here's what each team member might work on and how the pieces connect:

### 22.1 — Feature modules to build next

| Module | Folder | What it does |
|--------|--------|-------------|
| Auth | `auth/` | JWT login/register, password hashing |
| Token Purchase | `purchase/` | Buy tokens using wallet balance |
| Wallet | `wallet/` | Top-up coins via bKash/Nagad |
| QR Validation | `qr/` | Generate/scan QR codes for meal entry |
| Admin | `admin/` | Meal management, daily menu CRUD |
| Notification | `notification/` | Push notifications for marketplace events |

### 22.2 — How a new feature module should look

```
backend/src/main/java/dsi/ruet/backend/
└── wallet/                          ← new feature folder
    ├── WalletService.java           ← business logic
    ├── WalletController.java        ← REST endpoints
    ├── dto/
    │   ├── TopUpRequest.java        ← input DTO
    │   └── WalletResponse.java      ← output DTO
    └── exception/
        └── WalletException.java     ← custom exception
```

Every feature follows the same pattern: **Entity → Repository → Service → Controller → DTOs → Exception**.

### 22.3 — How features will connect

```
MarketplaceService  ──uses──▶  TokenRepository (shared)
PurchaseService     ──uses──▶  TokenRepository (shared)
QRService           ──uses──▶  TokenRepository (shared)
WalletService       ──uses──▶  WalletRepository (shared)
PurchaseService     ──uses──▶  WalletRepository (shared)
```

Shared models and repositories are the glue between feature modules. That's why they live in `models/` and `repositories/` — not inside any feature folder.

---

## Quick Reference: Annotations Cheat Sheet

| Annotation | Where | What it does |
|-----------|-------|-------------|
| `@SpringBootApplication` | Main class | Activates Spring Boot |
| `@EnableScheduling` | Main class | Enables `@Scheduled` |
| `@Entity` | Model class | Maps to database table |
| `@Table(name="x")` | Model class | Sets table name |
| `@Id` | Field | Primary key |
| `@GeneratedValue(IDENTITY)` | Field | Auto-increment |
| `@Column(...)` | Field | Column constraints |
| `@ManyToOne` | Field | Foreign key relationship |
| `@OneToOne` | Field | 1:1 relationship |
| `@MapsId` | Field | Share primary key |
| `@Enumerated(STRING)` | Field | Store enum as string |
| `@PrePersist` | Method | Run before first save |
| `@Service` | Class | Business logic bean |
| `@RestController` | Class | HTTP handler bean |
| `@RequestMapping` | Class/method | URL prefix |
| `@GetMapping` | Method | Handle GET request |
| `@PostMapping` | Method | Handle POST request |
| `@RequestHeader` | Parameter | Read HTTP header |
| `@RequestBody` | Parameter | Read JSON body |
| `@PathVariable` | Parameter | Read URL path variable |
| `@Transactional` | Method/class | Database transaction |
| `@Scheduled` | Method | Run on a timer |
| `@Component` | Class | Generic Spring bean |
| `@Configuration` | Class | Config/bean definitions |
| `@RestControllerAdvice` | Class | Global exception handler |
| `@ExceptionHandler` | Method | Handle specific exception |
| `@RequiredArgsConstructor` | Class | Lombok: constructor for final fields |
| `@Data` | Class | Lombok: getters, setters, etc. |
| `@Builder` | Class | Lombok: builder pattern |
| `@Slf4j` | Class | Lombok: logging |
| `@Query` | Method | Custom JPQL query |
| `@Param` | Parameter | Named parameter in JPQL |

---

## Quick Reference: Maven Commands

```bash
./mvnw compile               # Compile only (check for errors)
./mvnw spring-boot:run       # Compile + start server
./mvnw test                  # Run unit tests
./mvnw clean                 # Delete target/ folder
./mvnw clean compile         # Clean recompile
./mvnw package               # Build JAR file
./mvnw dependency:tree       # Show all dependency versions
```

---

*This guide was written for the DSI RUET backend team. It covers Java basics through Spring Boot internals, all mapped to your actual project codebase.*
