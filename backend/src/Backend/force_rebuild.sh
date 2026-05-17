rm -rf target/
rm -rf ~/.m2/repository/tools/vlab/kberry/

# 1. Core bauen
cd ../Core
mvn clean install

# 2. Server bauen
cd ../Server
mvn clean install

# 3. Backend bauen
cd ../Backend
mvn clean install

# Rebuild alles
mvn clean install -U