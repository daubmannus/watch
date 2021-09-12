.PHONY: clean All

All:
	@echo "----------Building project:[ watchdirsw - Debug ]----------"
	@cd "watchdirsw" && "$(MAKE)" -f  "watchdirsw.mk"
clean:
	@echo "----------Cleaning project:[ watchdirsw - Debug ]----------"
	@cd "watchdirsw" && "$(MAKE)" -f  "watchdirsw.mk" clean
