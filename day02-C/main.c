// Day 2: Red-Nosed Reports

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define BUFFER_SIZE 1024
#define MAX_LINE_SIZE 128
#define MAX_TOKENS 10

struct tokens_t
{
    int token[MAX_TOKENS];
    int count;
};

struct tokens_t tokenize(char *input)
{
    struct tokens_t tokens;
    tokens.count = 0;

    char *value;
    char *line_ptr = input;
    while ((value = strsep(&line_ptr, " ")))
        tokens.token[tokens.count++] = atoi(value);
    return tokens;
}

enum Status
{
    INCREASE,
    DECREASE,
    UNKNOWN
};
// Returns 1 if safe, 0 if unsafe
int is_safe(struct tokens_t tokens, int ignored)
{
    enum Status status = UNKNOWN;

    int old_value = -1;
    for (int i = 0; i < tokens.count; i++)
    {
        if (i == ignored)
            continue;
        int value = tokens.token[i];
        if (old_value == -1)
        {
            old_value = value;
            continue;
        }

        int diff = abs(value - old_value);
        if (diff == 0 || diff > 3)
            return 0;

        if (status == UNKNOWN)
            status = value > old_value ? INCREASE : DECREASE;
        if ((status == INCREASE && value < old_value) ||
            (status == DECREASE && value > old_value))
            return 0;
        old_value = value;
    }
    return 1;
}

int is_tolerated(struct tokens_t tokens)
{
    for (int i = 0; i < tokens.count; i++)
        if (is_safe(tokens, i))
            return 1;
    return 0;
}

int main()
{
    int fd = open("input.txt", O_RDONLY);
    if (fd == -1)
    {
        perror("Error while opening file");
        exit(EXIT_FAILURE);
    }

    int safe_count = 0;
    int tolerated_count = 0;

    char buffer[BUFFER_SIZE];
    char line_buffer[MAX_LINE_SIZE];

    ssize_t bytes;
    int last_byte = 0;
    struct tokens_t tokens;
    while ((bytes = read(fd, buffer, sizeof(buffer))) > 0)
    {
        for (int i = 0; i < bytes; i++)
        {
            if (buffer[i] == '\n')
            {
                tokens = tokenize(line_buffer);
                safe_count += is_safe(tokens, -1);
                tolerated_count += is_tolerated(tokens);
                line_buffer[0] = '\0';
                last_byte = 0;
            }
            else
            {
                line_buffer[last_byte++] = buffer[i];
                line_buffer[last_byte + 1] = '\0';
            }
        }
    }

    if (bytes == -1)
    {
        perror("Error while reading file");
        close(fd);
        exit(EXIT_FAILURE);
    }
    close(fd);

    printf("Safe reports: %d\n", safe_count);
    printf("Tolerated reports: %d\n", tolerated_count);

    return EXIT_SUCCESS;
}