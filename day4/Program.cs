// Day 4: Ceres Search

static List<string> GetPaddedInput(string word, char pad)
{
    int paddingSize = word.Length - 1;
    StreamReader reader = new("input.txt");

    // Padding to avoid checking boundaries too often
    List<string> output = [];

    string line = reader.ReadLine();
    int lineLength = line.Length;

    string padding = new(pad, lineLength + 2 * paddingSize);
    string sidePadding = new(pad, paddingSize);
    for (int i = 0; i < paddingSize; i++)
        output.Add(padding);

    do
    {
        output.Add(sidePadding + line + sidePadding);
    } while ((line = reader.ReadLine()) != null);

    for (int i = 0; i < paddingSize; i++)
        output.Add(padding);

    return output;
}

Console.WriteLine("Hello, World!");

static int CountFromLetter(string word, List<string> padded, int i, int j)
{
    int res = 0;
    int[] values = [-1, 0, 1];
    foreach (int h in values)
    {
        foreach (int v in values)
        {
            if (v == 0 && h == 0) continue;
            bool full = true;
            for (int index = 0; index < word.Length; index++)
                if (padded[i + v * index][j + h * index] != word[index])
                    full = false;
            if (full)
                res++;
        }
    }
    return res;
}

// Palindromes are counted twice
static long FirstPart(string word, List<string> padded)
{
    long count = 0;
    int paddingSize = word.Length - 1;
    int width = padded[0].Length;
    int height = padded.Count;

    for (int i = paddingSize; i < height - paddingSize; i++)
        for (int j = paddingSize; j < width - paddingSize; j++)
            count += CountFromLetter(word, padded, i, j);
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

static long SecondPart(string word, List<string> padded)
{
    long count = 0;
    int paddingSize = word.Length - 1;
    int width = padded[0].Length;
    int height = padded.Count;

    for (int i = paddingSize; i < height - paddingSize; i++)
        for (int j = paddingSize; j < width - paddingSize; j++)
            if (padded[i][j] == 'A' && MatchCross(padded, i, j))
                count++;
    return count;
}


string word = "XMAS";
List<string> padded = GetPaddedInput(word, '*');
long firstPartCount = FirstPart(word, padded);
Console.WriteLine(firstPartCount);
long secondPartCount = SecondPart(word, padded);
Console.WriteLine(secondPartCount);