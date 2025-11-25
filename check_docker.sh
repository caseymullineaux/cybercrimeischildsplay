#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Docker Environment Check${NC}"
echo ""

# Check if Docker is installed
echo -n "Checking Docker... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
    docker --version
else
    echo -e "${RED}✗ Not found${NC}"
    echo -e "${YELLOW}Please install Docker: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

echo ""

# Check if Docker is running
echo -n "Checking Docker daemon... "
if docker info &> /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${RED}✗ Not running${NC}"
    echo -e "${YELLOW}Please start Docker Desktop${NC}"
    exit 1
fi

echo ""

# Check if Docker Compose is installed
echo -n "Checking Docker Compose... "
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
    docker-compose --version
else
    echo -e "${RED}✗ Not found${NC}"
    echo -e "${YELLOW}Please install Docker Compose${NC}"
    exit 1
fi

echo ""

# Check if port 5000 is available
echo -n "Checking port 5000... "
if lsof -Pi :5000 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠ Port 5000 is already in use${NC}"
    echo -e "${YELLOW}You may need to change the port in docker-compose.yml${NC}"
else
    echo -e "${GREEN}✓ Available${NC}"
fi

echo ""
echo -e "${GREEN}✅ All checks passed!${NC}"
echo ""
echo -e "${BLUE}Ready to start the application:${NC}"
echo -e "  ${GREEN}docker-compose up${NC}"
echo ""
echo -e "Or use the Makefile:"
echo -e "  ${GREEN}make up${NC}"
