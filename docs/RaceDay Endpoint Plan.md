# RaceDay – API Endpoint Plan

System roles: **Organiser** (creates and manages events, categories, and views results) and **Participant** (registers, enrols in categories, views own results/payments).

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Registers a new user as either an Organiser or a Participant. | None (public) | { fullName, email, password, role, phoneNumber } | 201 Created – user record (no password) 400 Bad Request – validation error 409 Conflict – email already registered |
| POST | /api/auth/login | Authenticates a user and returns a JWT access token. | None (public) | { email, password } | 200 OK – { token, userId, role } 401 Unauthorized – invalid credentials |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any (logged in) | None | 200 OK – user profile 401 Unauthorized |
| PUT | /api/users/me | Updates the logged-in user's own profile details. | Any (logged in) | { fullName, phoneNumber } | 200 OK – updated profile 400 Bad Request |
| GET | /api/users/{id} | Retrieves a specific user's public profile (e.g. an Organiser viewing a participant). | Organiser | None | 200 OK – user profile 404 Not Found |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all events, with optional filters (date, location, status). | Any (public) | None | 200 OK – array of events |
| GET | /api/events/{id} | Retrieves full detail for a single event, including its categories. | Any (public) | None | 200 OK – event detail 404 Not Found |
| POST | /api/events | Creates a new event owned by the logged-in Organiser. | Organiser | { name, description, eventDate, location } | 201 Created – event record 400 Bad Request |
| PUT | /api/events/{id} | Updates an event's details. Only the owning Organiser may edit it. | Organiser (owner only) | { name, description, eventDate, location, status } | 200 OK – updated event 403 Forbidden – not the owner 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event and its associated categories. | Organiser (owner only) | None | 204 No Content 403 Forbidden 404 Not Found |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all race categories for a given event. | Any (public) | None | 200 OK – array of categories 404 Not Found |
| POST | /api/events/{eventId}/categories | Adds a new category (e.g. 5km, 10km) to an event. | Organiser (owner only) | { name, distanceKm, maxParticipants, fee, startTime } | 201 Created – category record 403 Forbidden 404 Not Found |
| PUT | /api/categories/{id} | Updates a category's details. | Organiser (owner only) | { name, distanceKm, maxParticipants, fee, startTime } | 200 OK – updated category 403 Forbidden 404 Not Found |
| DELETE | /api/categories/{id} | Removes a category from an event. | Organiser (owner only) | None | 204 No Content 403 Forbidden 404 Not Found |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/categories/{categoryId}/enrolments | Enrols the logged-in Participant into a race category. | Participant | None | 201 Created – enrolment record 404 Not Found – category does not exist 409 Conflict – already enrolled, or category full |
| GET | /api/users/me/enrolments | Lists all enrolments belonging to the logged-in Participant. | Participant | None | 200 OK – array of enrolments |
| GET | /api/categories/{categoryId}/enrolments | Lists all participants enrolled in a category. | Organiser (owner only) | None | 200 OK – array of enrolments 403 Forbidden |
| DELETE | /api/enrolments/{id} | Cancels an enrolment. | Participant (owner) or Organiser | None | 204 No Content 403 Forbidden 404 Not Found |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/result | Captures the finish time and position for a participant's enrolment. | Organiser (owner only) | { finishTime, position, status } | 201 Created – result record 403 Forbidden 404 Not Found – enrolment does not exist 409 Conflict – result already captured |
| GET | /api/enrolments/{enrolmentId}/result | Retrieves the result for a single enrolment. | Participant (owner) or Organiser | None | 200 OK – result record 404 Not Found |
| GET | /api/categories/{categoryId}/results | Retrieves the full results/leaderboard for a category, ordered by position. | Any (public) | None | 200 OK – array of results 404 Not Found |
