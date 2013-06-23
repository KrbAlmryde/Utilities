langToscheme = {'Java': ['Darkside', 'Frontier', 'Monokai Soda',
                         'Peacock', 'Solarized Dark', 'SunBurst'
                        ],
                'Python': ['Darkside', 'Frontier', 'Monokai Soda',
                           'Phix Dark', 'SunBurst', 'Tomorrow-Night Bright'
                          ],
                'Bash': ['Dobdark', 'EspressoLibre', 'LastNight',
                          'Phix Dark', 'SunBurst', 'Tomorrow-Night Bright'
                        ]
                }


def lang_to_scheme(language, colorScheme):
    if language in langToscheme:
        langToscheme[language].append(colorScheme)
    else:
        langToscheme[language] = [colorScheme]
