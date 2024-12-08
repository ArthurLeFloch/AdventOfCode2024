// Day 8: Resonant Collinearity

#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>

struct Position
{
    int x, y;
};

class Problem
{
public:
    std::unordered_map<char, std::vector<Position>> positions;
    int size = -1;

    Problem(const std::string &filePath)
    {
        std::ifstream f(filePath);

        if (!f.is_open())
        {
            std::cerr << "Error opening the file!";
            return;
        }

        int x, y = 0;
        std::string s;
        while (getline(f, s))
        {
            x = 0;
            for (const char c : s)
            {
                if (c != '.')
                    positions[c].push_back({x, y});
                x++;
            }
            y++;
            if (size == -1)
                size = s.size();
        }
    }

    bool inside(int x, int y) const
    {
        return x >= 0 && y >= 0 && x < size && y < size;
    }
};

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

                if (p.inside(newX, newY) && !seen[newX][newY])
                {
                    seen[newX][newY] = true;
                    sum++;
                }

                newX = first.x + (first.x - second.x);
                newY = first.y + (first.y - second.y);

                if (p.inside(newX, newY) && !seen[newX][newY])
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
                while (p.inside(x + dx, y + dy))
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
                while (p.inside(x - dx, y - dy))
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

    std::cout << "First part: " << firstPart(p) << std::endl;
    std::cout << "Second part: " << secondPart(p) << std::endl;

    return 0;
}
