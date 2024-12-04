// Day 4: Ceres Search
static string[] GetStringTable(string filePath)
{
    StreamReader reader = new(filePath);
    return reader.ReadToEnd().Trim().Split('\n');
}

static List<string> PadStringTable(string[] table, char pad, int amount)
{
    List<string> output = [];

    string linePadding = new(pad, table[0].Length + 2 * amount);
    string sidePadding = new(pad, amount);

    output.AddRange(Enumerable.Repeat(linePadding, amount));
    output.AddRange(table.Select(line => sidePadding + line + sidePadding));
    output.AddRange(Enumerable.Repeat(linePadding, amount));

    return output;
}

static int CountFromLetter(List<string> padded, string word, int i, int j)
{
    int res = 0;
    int[] dir = [-1, 0, 1];
    var directions = dir.SelectMany(h => dir, (h, v) => (h, v)).Where(t => t != (0, 0));
    foreach (var (h, v) in directions)
    {
        bool full = true;
        for (int index = 0; index < word.Length; index++)
            if (padded[i + v * index][j + h * index] != word[index])
                full = false;
        if (full)
            res++;
    }
    return res;
}

// Palindromes are counted twice. Not a problem here with the word XMAS.
static long FirstPart(string word, List<string> padded)
{
    long count = 0;

    int paddingSize = word.Length - 1;
    int width = padded[0].Length;
    int height = padded.Count;

    for (int i = paddingSize; i < height - paddingSize; i++)
        for (int j = paddingSize; j < width - paddingSize; j++)
            count += CountFromLetter(padded, word, i, j);
    return count;
}

static bool MatchCross(List<string> l, int i, int j)
{
    char topLeft = l[i - 1][j - 1];
    char topRight = l[i - 1][j + 1];
    char bottomLeft = l[i + 1][j - 1];
    char bottomRight = l[i + 1][j + 1];

    if (topLeft == 'M')
    {
        if (topRight == 'M')
            return bottomLeft == 'S' && bottomRight == 'S';
        return topRight == 'S' && bottomLeft == 'M' && bottomRight == 'S';
    }
    if (topLeft == 'S')
    {
        if (topRight == 'S')
            return bottomLeft == 'M' && bottomRight == 'M';
        return topRight == 'M' && bottomLeft == 'S' && bottomRight == 'M';
    }
    return false;
}

static long SecondPart(List<string> padded)
{
    long count = 0;

    int width = padded[0].Length;
    int height = padded.Count;
    for (int i = 1; i < height - 1; i++)
        for (int j = 1; j < width - 1; j++)
            if (padded[i][j] == 'A' && MatchCross(padded, i, j))
                count++;
    return count;
}

string[] table = GetStringTable("input.txt");

string word = "XMAS";
List<string> padded = PadStringTable(table, '*', word.Length - 1);
long firstPartCount = FirstPart(word, padded);
Console.WriteLine($"First part: {firstPartCount}");

padded = PadStringTable(table, '*', 1);
long secondPartCount = SecondPart(padded);
Console.WriteLine($"Second part: {secondPartCount}");