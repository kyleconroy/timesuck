from setuptools import setup, find_packages
setup(
    name = "timesuck",
    version = "0.1",
    description = "Generate reports from your timesuck database",
    author = "Kyle Conroy",
    author_email = "kyle@twilio.com",
    url = "http://github.com/derferman/timesuck",
    keywords = ["time tracking", "timesuck"],
    packages = find_packages(),
    entry_points={
        'console_scripts': [
            'timesuck = timesuck:main',]},
    classifiers = [
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        "Topic :: Software Development :: Libraries :: Python Modules",
        ],
    )
