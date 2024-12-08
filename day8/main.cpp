#include <iostream>
#include <fstream>
#include <map>
#include <vector>

class Position
{
public:
    int x, y;
    Position(int x, int y) : x(x), y(y) {}
};

class Problem
{
public:
    std::map<char, std::vector<Position>> positions;
    int size = -1;

    Problem(std::string filePath)
    {
        std::ifstream f("input.txt");

        if (!f.is_open())
        {
            std::cerr << "Error opening the file!";
            return;
        }

        int y = 0;
        std::string s;
        while (getline(f, s))
        {
            for (int x = 0; x < s.size(); x++)
            {
                char c = s[x];
                if (c != '.')
                    positions[c].push_back(Position(x, y));
            }
            y++;
            if (size == -1)
                size = s.size();
        }
    }
};

bool outside(int x, int y, int size)
{
    return x < 0 || y < 0 || x >= size || y >= size;
}

int firstPart(const Problem &p)
{
    std::vector<std::vector<bool>> seen(p.size, std::vector<bool>(p.size, false));

    int sum = 0;

    for (const auto &[symbol, positions] : p.positions)
    {
        int n = positions.size();
        for (int i = 0; i < n - 1; ++i)
        {
            Position first = positions[i];
            for (int j = i + 1; j < n; ++j)
            {
                Position second = positions[j];

                int newX = second.x + (second.x - first.x);
                int newY = second.y + (second.y - first.y);

                if (!outside(newX, newY, p.size) && !seen[newX][newY])
                {
                    seen[newX][newY] = true;
                    sum++;
                }

                newX = first.x + (first.x - second.x);
                newY = first.y + (first.y - second.y);

                if (!outside(newX, newY, p.size) && !seen[newX][newY])
                {
                    seen[newX][newY] = true;
                    sum++;
                }
            }
        }
    }

    return sum;
}

int secondPart(const Problem &p)
{
    std::vector<std::vector<bool>> seen(p.size, std::vector<bool>(p.size, false));

    int sum = 0;

    for (const auto &[symbol, positions] : p.positions)
    {
        int n = positions.size();
        for (int i = 0; i < n; ++i)
        {
            Position first = positions[i];

            if (n > 1 && !seen[first.x][first.y])
            {
                sum++;
                seen[first.x][first.y] = true;
            }
            for (int j = i + 1; j < n; ++j)
            {
                Position second = positions[j];

                int dx = second.x - first.x;
                int dy = second.y - first.y;

                int x = second.x;
                int y = second.y;
                while (!outside(x + dx, y + dy, p.size))
                {
                    x += dx;
                    y += dy;
                    if (!seen[x][y])
                    {
                        sum++;
                        seen[x][y] = true;
                    }
                }

                x = first.x;
                y = first.y;
                while (!outside(x - dx, y - dy, p.size))
                {
                    x -= dx;
                    y -= dy;
                    if (!seen[x][y])
                    {
                        sum++;
                        seen[x][y] = true;
                    }
                }
            }
        }
    }

    return sum;
}

int main()
{
    Problem p("input.txt");

    Problem &pp = p;

    std::cout << "First part: " << firstPart(pp) << std::endl;
    std::cout << "Second part: " << secondPart(pp) << std::endl;

    return 0;
}
