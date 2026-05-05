# My Events page

it must handle events that are coming from API: host/o/c/events

## API Format

### GET

```agsl
{
    "actions": {
        "create": {
            "method": "POST",
            "href": "http://192.168.0.49:8080/o/c/events/"
        },
        "createBatch": {
            "method": "POST",
            "href": "http://192.168.0.49:8080/o/c/events/batch"
        }
    },
    "facets": [],
    "items": [
        {
            "actions": {
                "versions": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/by-external-reference-code/58c98bbc-1e7b-a074-b6e7-0254fb568790/versions"
                },
                "permissions": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/34476/permissions"
                },
                "get": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/34476"
                },
                "replace": {
                    "method": "PUT",
                    "href": "http://192.168.0.49:8080/o/c/events/34476"
                },
                "update": {
                    "method": "PATCH",
                    "href": "http://192.168.0.49:8080/o/c/events/34476"
                },
                "delete": {
                    "method": "DELETE",
                    "href": "http://192.168.0.49:8080/o/c/events/34476"
                }
            },
            "creator": {
                "additionalName": "",
                "contentType": "UserAccount",
                "externalReferenceCode": "3107f767-e6e1-0a06-b398-07279c0fc4dd",
                "familyName": "User",
                "givenName": "New",
                "id": 33743,
                "name": "New User"
            },
            "dateCreated": "2026-05-05T09:43:52Z",
            "dateModified": "2026-05-05T09:43:52Z",
            "defaultLanguageId": "en_US",
            "externalReferenceCode": "58c98bbc-1e7b-a074-b6e7-0254fb568790",
            "friendlyUrlPath": "58c98bbc-1e7b-a074-b6e7-0254fb568790",
            "friendlyUrlPath_i18n": {
                "en_US": "58c98bbc-1e7b-a074-b6e7-0254fb568790"
            },
            "id": 34476,
            "keywords": [],
            "objectEntryFolderExternalReferenceCode": "",
            "objectEntryFolderId": 0,
            "scopeId": 0,
            "status": {
                "code": 0,
                "label": "approved",
                "label_i18n": "Approved"
            },
            "taxonomyCategoryBriefs": [],
            "date": "1990-01-01T00:00:00.000Z",
            "name": "Birthday",
            "recurence": {
                "key": "yearly",
                "name": "yearly"
            }
        },
        {
            "actions": {
                "versions": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/by-external-reference-code/fce32bcb-dbc1-70d3-ec4e-603ab7e141c6/versions"
                },
                "permissions": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/34485/permissions"
                },
                "get": {
                    "method": "GET",
                    "href": "http://192.168.0.49:8080/o/c/events/34485"
                },
                "replace": {
                    "method": "PUT",
                    "href": "http://192.168.0.49:8080/o/c/events/34485"
                },
                "update": {
                    "method": "PATCH",
                    "href": "http://192.168.0.49:8080/o/c/events/34485"
                },
                "delete": {
                    "method": "DELETE",
                    "href": "http://192.168.0.49:8080/o/c/events/34485"
                }
            },
            "creator": {
                "additionalName": "",
                "contentType": "UserAccount",
                "externalReferenceCode": "3107f767-e6e1-0a06-b398-07279c0fc4dd",
                "familyName": "User",
                "givenName": "New",
                "id": 33743,
                "name": "New User"
            },
            "dateCreated": "2026-05-05T09:48:57Z",
            "dateModified": "2026-05-05T09:48:57Z",
            "defaultLanguageId": "en_US",
            "externalReferenceCode": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6",
            "friendlyUrlPath": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6",
            "friendlyUrlPath_i18n": {
                "en_US": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6"
            },
            "id": 34485,
            "keywords": [],
            "objectEntryFolderExternalReferenceCode": "",
            "objectEntryFolderId": 0,
            "scopeId": 0,
            "status": {
                "code": 0,
                "label": "approved",
                "label_i18n": "Approved"
            },
            "taxonomyCategoryBriefs": [],
            "date": "1992-05-05T00:00:00.000Z",
            "name": "Marriage",
            "recurence": {
                "key": "yearly",
                "name": "yearly"
            }
        }
    ],
    "lastPage": 1,
    "page": 1,
    "pageSize": 20,
    "totalCount": 2
}
```

### POST
#### Post body

```agsl
{
  "date": "1992-05-05",
  "name": "Marriage",
  "recurence": {
    "key": "yearly",
    "name": "Yearly"
  }
}
```

#### Result
```
{
    "actions": {
        "versions": {
            "method": "GET",
            "href": "http://192.168.0.49:8080/o/c/events/by-external-reference-code/fce32bcb-dbc1-70d3-ec4e-603ab7e141c6/versions"
        },
        "permissions": {
            "method": "GET",
            "href": "http://192.168.0.49:8080/o/c/events/34485/permissions"
        },
        "get": {
            "method": "GET",
            "href": "http://192.168.0.49:8080/o/c/events/34485"
        },
        "replace": {
            "method": "PUT",
            "href": "http://192.168.0.49:8080/o/c/events/34485"
        },
        "update": {
            "method": "PATCH",
            "href": "http://192.168.0.49:8080/o/c/events/34485"
        },
        "delete": {
            "method": "DELETE",
            "href": "http://192.168.0.49:8080/o/c/events/34485"
        }
    },
    "creator": {
        "additionalName": "",
        "contentType": "UserAccount",
        "externalReferenceCode": "3107f767-e6e1-0a06-b398-07279c0fc4dd",
        "familyName": "User",
        "givenName": "New",
        "id": 33743,
        "name": "New User"
    },
    "dateCreated": "2026-05-05T09:48:57Z",
    "dateModified": "2026-05-05T09:48:57Z",
    "defaultLanguageId": "en_US",
    "externalReferenceCode": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6",
    "friendlyUrlPath": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6",
    "friendlyUrlPath_i18n": {
        "en_US": "fce32bcb-dbc1-70d3-ec4e-603ab7e141c6"
    },
    "id": 34485,
    "keywords": [],
    "objectEntryFolderExternalReferenceCode": "",
    "objectEntryFolderId": 0,
    "scopeId": 0,
    "status": {
        "code": 0,
        "label": "approved",
        "label_i18n": "Approved"
    },
    "taxonomyCategoryBriefs": [],
    "date": "1992-05-05T00:00:00.000Z",
    "name": "Marriage",
    "recurence": {
        "key": "yearly",
        "name": "yearly"
    }
}
```


## Details

- events list
- add event feature
- delete event feature
