from pandas import DataFrame
import numpy as np
import re

df = DataFrame.from_csv("Z:\job_desc_sample.tsv", sep="\t", index_col=False)

# print(df.columns.values.tolist())
# print(df.shape)

df['Salary'] = np.NaN
df['HS'] = np.NaN
df['Bachelor'] = np.NaN

# loop through descriptions
for i in range(0,len(df['description'])):

    # if it finds a salary (any number following dollar sign), record it
    if re.findall('(?:\$)(\s)*((\d|\.|,|k)+)', df.loc[i,'description']):
        x = re.findall('(?:\$)(\s)*((\d|\.|,|k)+)', df.loc[i,'description'])

        # if multiple salaries listed, give the maximum
        JobSalariesFound = []
        for j in range(0,len(x)):
            thousand = False
            salary = x[j][1]
            # convert k to thousands
            if 'k' in salary:
                salary = salary.replace('k','.')
                thousand = True
            # remove trailing .
            if salary.endswith('.'):
                salary = salary[:-1]
            # remove all . except last if multiple occur
            if salary.count('.') > 1:
                salary = salary.replace('.','',salary.count('.')-1)
            # remove blanks
            if salary == '':
                salary = '0'
            try:
                salary = float(salary)
                if thousand == True:
                    salary = salary*1000
                JobSalariesFound.append(salary)
            except:
                print(salary + ' in row ' + str(i) + ' could not be converted to float')
                JobSalariesFound.append(0)
        maxSal = max(JobSalariesFound)
        if maxSal > 1000000:
            maxSal = 0
        df.loc[i,'Salary'] = maxSal

    # Determine if high school diploma is required
    hsWords = ['high school', 'diploma', ' ged ']
    if any(word in df.loc[i,'description'].lower() for word in hsWords):
        df.loc[i,'HS'] = True

    # Determine if bachelor's is required
    bsWords = ['undergrad', 'degree', 'b.s.','b.a.']
    if any(word in df.loc[i, 'description'].lower() for word in bsWords):
        df.loc[i, 'Bachelor'] = True

df.to_csv('Z:\job_desc_sample_WITHsalary.tsv', sep="\t")