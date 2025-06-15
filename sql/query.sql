-- name: CreateUser :execresult
INSERT INTO
    `users` (
        `username`,
        `first_name`,
        `last_name`,
        `password_hash`,
        `email`
    )
VALUES
    (?, ?, ?, ?, ?);

-- name: DeleteUserById :exec
DELETE FROM `users`
WHERE
    `id` = ?;