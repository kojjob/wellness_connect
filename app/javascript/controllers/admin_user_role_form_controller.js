import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-user-role-form"
export default class extends Controller {
  static targets = [
    "roleSelect",
    "roleSpecificSection",
    "roleSectionTitle",
    "providerFields",
    "patientFields",
    "adminFields",
    "superAdminFields"
  ]

  connect() {
    // Initialize on page load
    this.handleRoleChange()
  }

  handleRoleChange() {
    const selectedRole = this.roleSelectTarget.value

    // Hide all role-specific sections first
    this.hideAllRoleFields()

    // Show the appropriate section based on selected role
    switch(selectedRole) {
      case 'provider':
        this.showProviderFields()
        break
      case 'patient':
        this.showPatientFields()
        break
      case 'admin':
        this.showAdminFields()
        break
      case 'super_admin':
        this.showSuperAdminFields()
        break
      default:
        this.hideRoleSpecificSection()
    }
  }

  hideAllRoleFields() {
    if (this.hasProviderFieldsTarget) {
      this.providerFieldsTarget.style.display = 'none'
    }
    if (this.hasPatientFieldsTarget) {
      this.patientFieldsTarget.style.display = 'none'
    }
    if (this.hasAdminFieldsTarget) {
      this.adminFieldsTarget.style.display = 'none'
    }
    if (this.hasSuperAdminFieldsTarget) {
      this.superAdminFieldsTarget.style.display = 'none'
    }
  }

  showProviderFields() {
    this.roleSpecificSectionTarget.style.display = 'block'
    this.roleSectionTitleTarget.textContent = 'Provider Information'
    this.providerFieldsTarget.style.display = 'block'
  }

  showPatientFields() {
    this.roleSpecificSectionTarget.style.display = 'block'
    this.roleSectionTitleTarget.textContent = 'Patient Information'
    this.patientFieldsTarget.style.display = 'block'
  }

  showAdminFields() {
    this.roleSpecificSectionTarget.style.display = 'block'
    this.roleSectionTitleTarget.textContent = 'Admin Information'
    this.adminFieldsTarget.style.display = 'block'
  }

  showSuperAdminFields() {
    this.roleSpecificSectionTarget.style.display = 'block'
    this.roleSectionTitleTarget.textContent = 'Super Admin Information'
    this.superAdminFieldsTarget.style.display = 'block'
  }

  hideRoleSpecificSection() {
    this.roleSpecificSectionTarget.style.display = 'none'
  }
}

